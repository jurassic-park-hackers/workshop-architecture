class ProductsNotFoundException < StandardError
  attr_reader :products_ids

  def initialize(products_ids)
    @products_ids = products_ids
    super
  end
end
