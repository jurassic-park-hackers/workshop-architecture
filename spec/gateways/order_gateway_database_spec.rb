require 'rails_helper'
require './lib/orders/structs'

RSpec.describe OrderGatewayDatabase do
  let(:gateway) { described_class.new() }
  let(:customer) { Customer.create() }
  let(:product_one) { Product.create() }
  let(:product_two) { Product.create() }
  let(:order_products) { [OrderProductStruct.new(product_one.id, 1, 10.0), OrderProductStruct.new(product_two.id, 2, 20.0)] }

  describe '#save_order' do
    it 'save customer in order' do
      gateway.save_order(customer.id, order_products)

      order = Order.first
      expect(order.customer_id).to eq(customer.id)
    end

    it 'save order and returns order_id' do
      order_id = gateway.save_order(customer.id, order_products)

      order = Order.first
      expect(order_id).to eq(order.id)
    end

    it 'save all order_products' do
      order_id = gateway.save_order(customer.id, order_products)

      order_products = OrderProduct.where(order_id: order_id)
      expect(order_products.length).to eq(2)
      
      expect(order_products[0].product_id).to eq(order_products[0].product_id)
      expect(order_products[0].quantity).to eq(order_products[0].quantity)
      expect(order_products[0].price).to eq(order_products[0].price)

      expect(order_products[1].product_id).to eq(order_products[1].product_id)
      expect(order_products[1].quantity).to eq(order_products[1].quantity)
      expect(order_products[1].price).to eq(order_products[1].price)
    end
  end
end
