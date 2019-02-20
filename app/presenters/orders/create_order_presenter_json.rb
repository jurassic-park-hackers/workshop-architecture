require './lib/orders/presenters'

module Orders
  class CreateOrderPresenterJson < CreateOrderPresenter
    def initialize
      @status = :bad_request
      @errors = []
      @order = {:order_id => nil, :total_price => nil}
    end

    def show_error_customer_not_found
      @status = :not_found
      @errors += ['Customer not found.']
    end

    def show_error_product_not_found(product_id)
      @status = :not_found
      @errors += ['Product not found: ' + product_id.to_s]
    end

    def show_order(order_id, total_price)
      @status = :ok
      @order[:order_id] = order_id
      @order[:total_price] = total_price
    end

    def response
      {
        'status': @status,
        'json': create_json_response
      }
    end

    private
    
    def create_json_response
      if @errors.empty?
        if @order[:order_id].nil?
          json = {}
        else
          json = @order
        end
      else
        json = {:errors => @errors}
      end

      json
    end
  end
end
