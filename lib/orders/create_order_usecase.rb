require './lib/orders/structs'
require './lib/products/exceptions'
require './lib/orders/order_entity'

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
    total_price = OrderEntity.get_total_price(order_products)

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
end
