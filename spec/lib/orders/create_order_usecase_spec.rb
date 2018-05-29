require './lib/orders/create_order_usecase'
require './lib/products/gateways'
require './lib/orders/gateways'
require './lib/orders/presenters'
require './lib/customers/gateways'

RSpec.describe CreateOrderUsecase do
  let(:customer_gateway) { instance_double(CustomerGateway) }
  let(:product_gateway) { instance_double(ProductGateway) }
  let(:order_gateway) { instance_double(OrderGateway) }
  let(:presenter) { instance_double(CreateOrderPresenter) }
  let(:usecase) { described_class.new(customer_gateway, product_gateway, order_gateway, presenter) }
  
  context 'when an errors occurs' do
    context 'customer not found' do 
      let(:customer_id) { 999 }
      let(:products) { [] }

      before do
        allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(false)
      end

      it 'present customer not found' do
        expect(presenter).to receive(:show_error_customer_not_found)

        usecase.execute(customer_id, products)
      end

      it 'does not saves order' do
        allow(presenter).to receive(:show_error_customer_not_found)

        expect(order_gateway).to_not receive(:save_order)

        usecase.execute(customer_id, products)
      end
    end

    context 'product not found' do
      let(:customer_id) { 1 }
      let(:products) { [{ product_id: 555, quantity: 1 }] }

      before do
        allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
        allow(product_gateway).to receive(:find_products_by_ids).with([555]).and_raise(ProductsNotFoundException.new([555]))
      end

      it 'present product not found' do
        expect(presenter).to receive(:show_error_product_not_found).with(555)

        usecase.execute(customer_id, products)
      end

      it 'does not saves order' do
        allow(presenter).to receive(:show_error_product_not_found)

        expect(order_gateway).to_not receive(:save_order)

        usecase.execute(customer_id, products)
      end
    end
  end

  context 'success' do
    let(:customer_id) { 1 }
    let(:products) { [{ product_id: 555, quantity: 2 }, { product_id: 666, quantity: 7 }] }
    let(:product_one) { ProductStruct.new(555, 'product_one', 10.0) }
    let(:product_two) { ProductStruct.new(666, 'product_two' ,8.4) }
    let(:order_product_one) { OrderProductStruct.new(product_id=product_one.product_id, quantity=2, price=product_one.price) }
    let(:order_product_two) { OrderProductStruct.new(product_id=product_two.product_id, quantity=7, price=product_two.price) }

    before do
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
      allow(product_gateway).to receive(:find_products_by_ids).with([555, 666]).and_return([product_one, product_two])
    end

    it 'save order to customer with two products' do
      allow(presenter).to receive(:show_order)

      expect(order_gateway).to receive(:save_order).with(customer_id, [order_product_one, order_product_two])

      usecase.execute(customer_id, products)
    end

    it 'present success with order_id and total_price' do
      order_id = 22
      allow(order_gateway).to receive(:save_order).and_return(order_id)

      total_price = 78.8
      expect(presenter).to receive(:show_order).with(order_id, total_price)

      usecase.execute(customer_id, products)
    end
  end
end
