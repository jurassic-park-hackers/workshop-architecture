class CreateOrderUsecase
  def initialize(customer_gateway, product_gateway, order_gateway, create_order_presenter)
    @customer_gateway = customer_gateway
    @product_gateway = product_gateway
    @order_gateway = order_gateway
    @presenter = create_order_presenter
  end

  def execute(customer_id, products_id_with_quantity)
    if not @customer_gateway.customer_exists?(customer_id)
      @presenter.show_error_customer_not_found
      return
    end

    order_product = nil

    for product_id_with_quantity in products_id_with_quantity
      begin
        product = @product_gateway.find_product_by_id(product_id_with_quantity[:product_id])
        order_product = OrderProductStruct.new(product.product_id, product_id_with_quantity[:quantity], product.price)
      rescue ProductNotFoundException
        @presenter.show_error_product_not_found(product_id_with_quantity[:product_id])
        return
      end
    end

    @order_gateway.save_order(customer_id, [order_product])
  end
end

class CustomerGateway
  def customer_exists?(customer_id)
  end
end

class ProductGateway
  def find_product_by_id(product_id)
  end
end

class OrderGateway
  def save_order(customer_id, order_products)
  end
end

class CreateOrderPresenter
  def show_error_customer_not_found
  end

  def show_error_product_not_found(product_id)
  end
end

ProductStruct = Struct.new(:product_id, :name, :price)

OrderProductStruct = Struct.new(:product_id, :quantity, :price)

class ProductNotFoundException < StandardError
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
        allow(product_gateway).to receive(:find_product_by_id).with(555).and_raise(ProductNotFoundException)

        expect(presenter).to receive(:show_error_product_not_found).with(555)

        usecase.execute(customer_id, products)
      end

      it 'does not saves order' do
        customer_id = 1
        products = [{ product_id: 555, quantity: 1 }]
        allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
        allow(product_gateway).to receive(:find_product_by_id).with(555).and_raise(ProductNotFoundException)
        allow(presenter).to receive(:show_error_product_not_found)

        expect(order_gateway).to_not receive(:save_order)

        usecase.execute(customer_id, products)
      end
    end
  end

  context 'success' do
    it 'save order to customer with products' do
      customer_id = 1
      products = [{ product_id: 555, quantity: 2 }]
      product = ProductStruct.new(product_id=555, price=10.0)
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
      allow(product_gateway).to receive(:find_product_by_id).with(555).and_return(product)

      order_product = OrderProductStruct.new(product_id=product.product_id, quantity=2, price=product.price)
      expect(order_gateway).to receive(:save_order).with(customer_id, [order_product])

      usecase.execute(customer_id, products)
    end
  end
end
