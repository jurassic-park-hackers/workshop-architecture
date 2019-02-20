ProductStruct = Struct.new(:product_id, :name, :price)

OrderProductStruct = Struct.new(:product_id, :quantity, :price)

OrderGatewayStruct = Struct.new(:order_id, :customer_id, :order_products)

ShowOrdersByCustomerResponse = Struct.new(:orders_response)
OrderResponse = Struct.new(:order_id, :customer_id, :total_price, :order_products)
