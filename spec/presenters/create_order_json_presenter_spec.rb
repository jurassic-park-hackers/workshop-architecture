require 'spec_helper'
require 'active_support/all'
require './lib/orders/presenters'

class CreateOrderJSONPresenter < CreateOrderPresenter
  attr_reader :data

  def initialize
    @data = {
      success: false,
      message_error: [],
      order_id: nil, 
      total_price: nil,
    }
  end

  def show_error_customer_not_found
    @data[:message_error] += ["Customer not found"]
  end

  def show_error_product_not_found(product_id)
    @data[:message_error] += ["Product #{product_id} not found"]
  end

  def show_order(order_id, total_price)
    @data[:success] = true
    @data[:order_id] = order_id
    @data[:total_price] = total_price
  end

  def response
    return ActiveSupport::JSON.encode(data)
  end
end

RSpec.describe CreateOrderJSONPresenter do
  let(:presenter) { described_class.new() }

  context 'when success' do
    it 'show order_id and total_price' do
      order_id = 11
      total_price = 22.0
      presenter.show_order(order_id, total_price)

      result = presenter.response

      result = ActiveSupport::JSON.decode(result)
      expect(result).to eq(
        { 
          "success" => true, 
          "message_error" => [],
          "order_id" => order_id, 
          "total_price" => total_price,
        })
    end
  end

  context 'when error occurs' do
    it 'show product not found' do
      product_one_id = 33
      product_two_id = 44
      presenter.show_error_product_not_found(product_one_id)
      presenter.show_error_product_not_found(product_two_id)

      result = presenter.response

      result = ActiveSupport::JSON.decode(result)
      expect(result).to eq(
      { 
        "success" => false, 
        "message_error" => [
          "Product #{product_one_id} not found", 
          "Product #{product_two_id} not found"
        ],
        "order_id" => nil, 
        "total_price" => nil,
      })
    end

    it 'show customer not found' do
      presenter.show_error_customer_not_found

      result = presenter.response

      result = ActiveSupport::JSON.decode(result)
      expect(result).to eq(
      { 
        "success" => false, 
        "message_error" => ['Customer not found'],
        "order_id" => nil, 
        "total_price" => nil,
      })
    end
  end
end
