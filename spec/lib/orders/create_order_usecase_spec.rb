class CreateOrderUsecase
  def initialize(customer_gateway, create_order_presenter)
    @customer_gateway = customer_gateway
    @presenter = create_order_presenter
  end

  def execute(customer_id, products)
    if not @customer_gateway.customer_exists?(customer_id)
      @presenter.show_error_customer_not_found
    end

    for product in products
      @presenter.show_error_product_not_found(product[:product_id])
    end
  end
end

class CustomerGateway
  def customer_exists?(customer_id)
  end
end

class CreateOrderPresenter
  def show_error_customer_not_found
  end

  def show_error_product_not_found(product_id)
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
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(false)

      expect(presenter).to receive(:show_error_customer_not_found)

      usecase.execute(customer_id, products)
    end

    it 'product not found' do
      customer_id = 1
      products = [{ product_id: 555, quantity: 1 }]
      allow(customer_gateway).to receive(:customer_exists?).with(customer_id).and_return(true)

      expect(presenter).to receive(:show_error_product_not_found).with(555)

      usecase.execute(customer_id, products)
    end
  end
end
