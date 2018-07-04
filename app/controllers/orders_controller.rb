require './lib/orders/create_order_usecase'
require './app/presenters/orders/create_order_presenter_json'

class OrdersController < ActionController::Base
  def create
    customer_gateway = CustomerGatewayDatabase.new
    product_gateway = ProductGatewayDatabase.new
    order_gateway = OrderGatewayDatabase.new
    presenter = CreateOrderPresenterJson.new

    CreateOrderUsecase.new(customer_gateway, product_gateway, order_gateway, presenter)
      .execute(params[:customer_id], get_products_id_with_quantity)

    render presenter.response
  end

  private

  def get_products_id_with_quantity
    params[:products_id_with_quantity].map{ |p| {product_id: p[:product_id].to_i, quantity: p[:quantity].to_f} }
  end
end
