require 'rails_helper'
require './lib/products/exceptions'

RSpec.describe ProductGatewayDatabase do
  let(:gateway) { described_class.new() }

  describe '#find_products_by_ids' do
    context 'when all products exists' do
      it 'returns all products' do
        product_one = Product.create()
        product_two = Product.create()
        product_not_searched = Product.create()

        result = gateway.find_products_by_ids([product_one.id, product_two.id])

        expect(result).to match_array [product_one, product_two]
      end
    end

    context 'when at least one product does not exists' do
      it 'raise an exception' do
        product = Product.create()

        expect{ gateway.find_products_by_ids([product.id, 123]) }.to raise_error{ |error|
          expect(error).to be_a(ProductsNotFoundException)
          expect(error.products_ids).to match_array [123] }
      end
    end
  end
end
