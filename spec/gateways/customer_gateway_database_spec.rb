require 'rails_helper'

RSpec.describe CustomerGatewayDatabase do
  let(:gateway) { described_class.new() }

  describe '#customer_exists?' do
    context 'when customer exists' do
      it 'returns true' do
        customer = Customer.create()

        result = gateway.customer_exists?(customer.id)

        expect(result).to be true
      end
    end

    context 'when customer does not exists' do
      it 'returns false' do
        result = gateway.customer_exists?(123)

        expect(result).to be false
      end
    end
  end
end
