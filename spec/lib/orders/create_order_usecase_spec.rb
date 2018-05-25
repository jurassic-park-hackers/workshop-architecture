class CreateOrderUsecase
  def initialize(customer_gateway, create_order_presenter)
    @customer_gateway = customer_gateway
    @presenter = create_order_presenter
  end

  def execute(customer_id, products)
    @presenter.show_error_customer_not_found
  end
end

class CustomerGateway
end

class CreateOrderPresenter
  def show_error_customer_not_found
  end
end

RSpec.describe CreateOrderUsecase do
  let(:customer_gateway) { instance_double(CustomerGateway) }
  let(:presenter) { instance_double(CreateOrderPresenter) }
  let(:usecase) { described_class.new(customer_gateway, presenter) }
  
  context 'present error when' do
    it 'customer not found' do
      customer_id = 999
      products = []

      expect(presenter).to receive(:show_error_customer_not_found)

      usecase.execute(customer_id, products)
    end
  end
end
