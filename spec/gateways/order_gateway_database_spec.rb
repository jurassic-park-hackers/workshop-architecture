require 'rails_helper'

RSpec.describe OrderGatewayDatabase do
  let(:gateway) { described_class.new() }
  let(:customer) { Customer.create() }
  let(:product_one) { Product.create() }
  let(:product_two) { Product.create() }
  let(:order_products) {
    [
      OrderProduct.new(product_id: product_one.id, quantity: 1, price: 10.0),
      OrderProduct.new(product_id: product_two.id, quantity: 2, price: 20.0)
    ]
  }

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

      order_products_database = OrderProduct.where(order_id: order_id)
      expect(order_products_database.length).to eq(2)
      
      expect(order_products_database[0].product_id).to eq(order_products[0].product_id)
      expect(order_products_database[0].quantity).to eq(order_products[0].quantity)
      expect(order_products_database[0].price).to eq(order_products[0].price)

      expect(order_products_database[1].product_id).to eq(order_products[1].product_id)
      expect(order_products_database[1].quantity).to eq(order_products[1].quantity)
      expect(order_products_database[1].price).to eq(order_products[1].price)
    end
  end

  describe '#get_orders_by_customer_id' do
    it 'filter by customer by id' do
      Order.create(customer_id: customer.id)

      expect(gateway.get_orders_by_customer_id(999)).to eq([])
    end

    context 'when customer has not orders' do
      it 'returns empty list' do
        expect(gateway.get_orders_by_customer_id(customer.id)).to eq([])
      end
    end

    context 'when customer has at least one order' do
      it 'returns orders' do
        order = Order.create(customer_id: customer.id)
        order_products = [
          OrderProduct.create(order_id: order.id, product_id: product_one.id, quantity: 1, price: 10.0),
          OrderProduct.create(order_id: order.id, product_id: product_two.id, quantity: 2, price: 15.0),
        ]

        orders = gateway.get_orders_by_customer_id(customer.id)

        expect(orders.length).to eq(1)
        expect(orders[0].order_products.length).to eq(2)

        expect(orders[0].customer_id).to eq(customer.id)

        expect(orders[0].order_products[0].product_id).to eq(order_products[0].product_id)
        expect(orders[0].order_products[0].quantity).to eq(order_products[0].quantity)
        expect(orders[0].order_products[0].price).to eq(order_products[0].price)

        expect(orders[0].order_products[1].product_id).to eq(order_products[1].product_id)
        expect(orders[0].order_products[1].quantity).to eq(order_products[1].quantity)
        expect(orders[0].order_products[1].price).to eq(order_products[1].price)
      end
    end
  end

end
