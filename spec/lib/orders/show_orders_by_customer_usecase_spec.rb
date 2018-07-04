require './lib/customers/gateways'
require './lib/orders/structs'
require './lib/orders/order_entity'

class ShowOrdersByCustomerUsecase
	def initialize(customer_gateway, order_gateway, show_orders_by_customer_presenter)
    @customer_gateway = customer_gateway
    @order_gateway = order_gateway
    @presenter = show_orders_by_customer_presenter
	end

	def execute(customer_id)
    if not @customer_gateway.customer_exists?(customer_id)
      @presenter.error_customer_not_found(customer_id)
      return
    end

    orders = @order_gateway.get_orders_by_customer_id(customer_id)
    response = ShowOrdersByCustomerResponse.new([])
    for order in orders
      total_price = OrderEntity.get_total_price(order.order_products)
      response.orders_response += [
        OrderResponse.new(order.order_id, order.customer_id, total_price, order.order_products)
      ]
    end

    @presenter.show_orders(response)
	end
end

class ShowOrdersByCustomerPresenter
  def show_orders(orders); end
  def error_customer_not_found(customer_id); end
end

RSpec.describe ShowOrdersByCustomerUsecase do
	let(:customer_gateway) { instance_double(CustomerGateway) }
  let(:order_gateway) { instance_double(OrderGateway) }
  let(:presenter) { instance_double(ShowOrdersByCustomerPresenter) }
  let(:usecase) { described_class.new(customer_gateway, order_gateway, presenter) }
  let(:customer_id) { 123 }
  
  context 'when customer has not orders' do
    it 'presents empty list' do
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
      allow(order_gateway).to receive(:get_orders_by_customer_id).with(customer_id).and_return([])

      expect(presenter).to receive(:show_orders).with(ShowOrdersByCustomerResponse.new([]))

      usecase.execute(customer_id)
    end
  end

  context 'when customer does not exist' do
    it 'presents error' do
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(false)

      expect(presenter).to receive(:error_customer_not_found).with(customer_id)

      usecase.execute(customer_id)
    end
  end

  context 'when customer has at least one order' do
    it 'presents orders' do
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)
      orders = [
        OrderGatewayStruct.new(456, customer_id, [
          OrderProductStruct.new(789, 6, 100),
          OrderProductStruct.new(101, 3, 200),
        ])
      ]
      allow(order_gateway).to receive(:get_orders_by_customer_id).with(customer_id).and_return(orders)

      response = ShowOrdersByCustomerResponse.new([
        OrderResponse.new(456, customer_id, 1200, [
          OrderProductStruct.new(789, 6, 100),
          OrderProductStruct.new(101, 3, 200),
        ])
      ])
      expect(presenter).to receive(:show_orders).with(response)

      usecase.execute(customer_id)
    end
  end
  
end
