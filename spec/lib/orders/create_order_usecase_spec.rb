class CreateOrderUsecase
  def initialize(customer_gateway, product_gateway, order_gateway, create_order_presenter)
    @customer_gateway = customer_gateway
    @product_gateway = product_gateway
    @order_gateway = order_gateway
    @presenter = create_order_presenter
  end

  def execute(customer_id, products_id_with_quantity)
    return if not customer_exists?(customer_id)

    products, has_error = find_products(products_id_with_quantity)
    return if has_error

    order_products = get_order_products(products, products_id_with_quantity)
    total_price = get_total_price(order_products)

    order_id = @order_gateway.save_order(customer_id, order_products)
    @presenter.show_order(order_id, total_price.round(2))
  end

  private

  def customer_exists?(customer_id)
    if not @customer_gateway.customer_exists?(customer_id)
      @presenter.show_error_customer_not_found
      return false
    end

    return true
  end

  def find_products(products_id_with_quantity)
    begin
      products_ids = products_id_with_quantity.map { |p| p[:product_id] }
      return @product_gateway.find_products_by_ids(products_ids), false
    rescue ProductsNotFoundException => ex
      for product_id in ex.products_ids
        @presenter.show_error_product_not_found(product_id)
      end

      return [], true
    end
  end

  def get_order_products(products, products_id_with_quantity)
    order_products = []

    for product in products
      quantity = products_id_with_quantity.select { |p| p[:product_id] == product.product_id }[0][:quantity]
      order_products += [OrderProductStruct.new(product.product_id, quantity, product.price)]
    end

    return order_products
  end

  def get_total_price(order_products)
    total_price = 0

    for order_product in order_products
      total_price += order_product.price * order_product.quantity
    end

    return total_price
  end
end

class CustomerGateway
  def customer_exists?(customer_id); end
end

class ProductGateway
  def find_products_by_ids(products_ids); end
end

class OrderGateway
  def save_order(customer_id, order_products); end
end

class CreateOrderPresenter
  def show_error_customer_not_found; end

  def show_error_product_not_found(product_id); end

  def show_order(order_id, total_price); end
end

ProductStruct = Struct.new(:product_id, :name, :price)

OrderProductStruct = Struct.new(:product_id, :quantity, :price)

class ProductsNotFoundException < StandardError
  attr_reader :products_ids

  def initialize(products_ids)
    @products_ids = products_ids
    super
  end
end

RSpec.describe CreateOrderUsecase do
  let(:customer_gateway) { instance_double(CustomerGateway) }
  let(:product_gateway) { instance_double(ProductGateway) }
  let(:order_gateway) { instance_double(OrderGateway) }
  let(:presenter) { instance_double(CreateOrderPresenter) }
  let(:usecase) { described_class.new(customer_gateway, product_gateway, order_gateway, presenter) }
  
  context 'when an errors occurs' do
    context 'customer not found' do 
      it 'present customer not found' do
        customer_id = 999
        products = []
        allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(false)

        expect(presenter).to receive(:show_error_customer_not_found)

        usecase.execute(customer_id, products)
      end

      it 'does not saves order' do
        customer_id = 999
        products = []
        allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(false)
        allow(presenter).to receive(:show_error_customer_not_found)

        expect(order_gateway).to_not receive(:save_order)

        usecase.execute(customer_id, products)
      end
    end

    context 'product not found' do
      it 'present product not found' do
        customer_id = 1
        products = [{ product_id: 555, quantity: 1 }]
        allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
        allow(product_gateway).to receive(:find_products_by_ids).with([555]).and_raise(ProductsNotFoundException.new([555]))

        expect(presenter).to receive(:show_error_product_not_found).with(555)

        usecase.execute(customer_id, products)
      end

      it 'does not saves order' do
        customer_id = 1
        products = [{ product_id: 555, quantity: 1 }]
        allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
        allow(product_gateway).to receive(:find_products_by_ids).with([555]).and_raise(ProductsNotFoundException.new([555]))
        allow(presenter).to receive(:show_error_product_not_found)

        expect(order_gateway).to_not receive(:save_order)

        usecase.execute(customer_id, products)
      end
    end
  end

  context 'success' do
    it 'save order to customer with one product' do
      customer_id = 1
      products = [{ product_id: 555, quantity: 2 }]
      product = ProductStruct.new(555, 'product', 10.0)
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
      allow(product_gateway).to receive(:find_products_by_ids).with([555]).and_return([product])
      allow(presenter).to receive(:show_order)

      order_product = OrderProductStruct.new(product_id=product.product_id, quantity=2, price=product.price)
      expect(order_gateway).to receive(:save_order).with(customer_id, [order_product])

      usecase.execute(customer_id, products)
    end

    it 'save order to customer with two products' do
      customer_id = 1
      products = [{ product_id: 555, quantity: 2 }, { product_id: 666, quantity: 7 }]
      product_one = ProductStruct.new(555, 'product_one', 10.0)
      product_two = ProductStruct.new(666, 'product_two' ,8.4)
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
      allow(product_gateway).to receive(:find_products_by_ids).with([555, 666]).and_return([product_one, product_two])
      allow(presenter).to receive(:show_order)

      order_product_one = OrderProductStruct.new(product_id=product_one.product_id, quantity=2, price=product_one.price)
      order_product_two = OrderProductStruct.new(product_id=product_two.product_id, quantity=7, price=product_two.price)
      expect(order_gateway).to receive(:save_order).with(customer_id, [order_product_one, order_product_two])

      usecase.execute(customer_id, products)
    end

    it 'present success with order_id and total_price' do
      customer_id = 1
      products = [{ product_id: 555, quantity: 2 }, { product_id: 666, quantity: 7 }]
      product_one = ProductStruct.new(555, 'product_one', 10.0)
      product_two = ProductStruct.new(666, 'product_two' ,8.4)
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
      allow(product_gateway).to receive(:find_products_by_ids).with([555, 666]).and_return([product_one, product_two])

      order_product_one = OrderProductStruct.new(product_id=product_one.product_id, quantity=2, price=product_one.price)
      order_product_two = OrderProductStruct.new(product_id=product_two.product_id, quantity=7, price=product_two.price)
      order_id = 22
      allow(order_gateway).to receive(:save_order).and_return(order_id)

      total_price = 78.8
      expect(presenter).to receive(:show_order).with(order_id, total_price)

      usecase.execute(customer_id, products)
    end

  end
end
