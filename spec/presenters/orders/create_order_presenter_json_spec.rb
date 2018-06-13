require './app/presenters/orders/create_order_presenter_json'

RSpec.describe CreateOrderPresenterJson do
  let(:presenter) { described_class.new() }

  describe '#respond' do
    context 'when nothing is presented' do
      it 'http status should be bad request' do
        response = presenter.response

        expect(response[:status]).to eq(:bad_request)
      end

      it 'response should be empty' do
        response = presenter.response

        expect(response[:data]).to eq({})
      end
    end

    context 'when customer not found is presented' do
      before(:each) do
        presenter.show_error_customer_not_found
      end

      it 'http status should be not found' do
        response = presenter.response

        expect(response[:status]).to eq(:not_found)
      end

      it 'response with customer not found error' do
        response = presenter.response

        expect(response[:data]).to eq({:errors => ['Customer not found.']})
      end
    end

    context 'when product not found is presented' do
      it 'http status should be not found' do
        presenter.show_error_product_not_found(123)

        response = presenter.response

        expect(response[:status]).to eq(:not_found)
      end

      it 'response product with error' do
        presenter.show_error_product_not_found(123)

        response = presenter.response

        expect(response[:data]).to eq({:errors => ['Product not found: 123']})
      end

      it 'response products with error when two products presented with error' do
        presenter.show_error_product_not_found(123)
        presenter.show_error_product_not_found(478)

        response = presenter.response

        expect(response[:data]).to eq({:errors => ['Product not found: 123', 'Product not found: 478']})
      end
    end

    context 'when order is presented' do
      let(:order_id) { 890 }
      let(:total_price) { 78912.78}

      before(:each) do
        presenter.show_order(order_id, total_price)
      end

      it 'http status should be ok' do
        response = presenter.response

        expect(response[:status]).to eq(:ok)
      end

      it 'response with order id and total_price' do
        response = presenter.response

        expect(response[:data]).to eq({:order_id => order_id, :total_price => total_price})
      end
    end
  end
end