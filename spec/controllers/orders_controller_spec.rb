require 'rails_helper'

RSpec.describe OrdersController do
    describe 'create order' do
        it 'create order with products and customer' do
            product = Product.create(price: 100.0)
            customer = Customer.create()
            products_id_with_quantity = [{product_id: product.id, quantity: 20}]

            post :create, as: :json, customer_id: customer.id, products_id_with_quantity: products_id_with_quantity, format: :json

            responseBody = ActiveSupport::JSON.decode(response.body)
            expect(response.status).to eq(200)
            expect(responseBody["order_id"]).to_not eq(nil)
            expect(responseBody["total_price"]).to eq("2000.0")
        end
    end
end