class OrderEntity
  class << self
    def get_total_price(order_products)
      total_price = 0

      for order_product in order_products
        total_price += order_product.price * order_product.quantity
      end

      return total_price
    end
  end
end
