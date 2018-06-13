require './lib/orders/create_order_usecase'
require './app/presenters/orders/create_order_presenter_json'

class OrdersController < ActionController::Base
  def create
    customer_gateway = CustomerGatewayDatabase.new
    product_gateway = ProductGatewayDatabase.new
    order_gateway = OrderGatewayDatabase.new
    presenter = CreateOrderPresenterJson.new

    CreateOrderUsecase.new(customer_gateway, product_gateway, order_gateway, presenter)
      .execute(params[:customer_id], params[:products_id_with_quantity])

    render presenter.response
  end
end
