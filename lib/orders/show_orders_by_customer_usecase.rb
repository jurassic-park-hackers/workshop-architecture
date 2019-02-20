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
