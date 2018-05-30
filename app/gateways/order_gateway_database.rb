require './lib/orders/gateways'

class OrderGatewayDatabase < OrderGateway
  def save_order(customer_id, order_products)
    order = Order.create(customer_id: customer_id)

    for order_product in order_products
      OrderProduct.create(
        product_id: order_product.product_id,
        quantity: order_product.quantity,
        price: order_product.price,
        order_id: order.id
      )
    end

    return order.id
  end
end
