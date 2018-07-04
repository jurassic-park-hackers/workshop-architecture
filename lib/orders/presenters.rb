class CreateOrderPresenter
  def show_error_customer_not_found; end
  def show_error_product_not_found(product_id); end
  def show_order(order_id, total_price); end
end

class ShowOrdersByCustomerPresenter
  def show_orders(orders); end
  def error_customer_not_found(customer_id); end
end
