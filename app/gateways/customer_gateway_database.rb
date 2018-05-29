require './lib/customers/gateways'

class CustomerGatewayDatabase < CustomerGateway
  def customer_exists?(customer_id)
    Customer.exists?(customer_id)
  end
end
