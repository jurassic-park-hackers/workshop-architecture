require './lib/products/gateways'
require './lib/products/exceptions'

class ProductGatewayDatabase < ProductGateway
  def find_products_by_ids(products_ids)
    products = Product.where(id: products_ids)
    
    products_ids_found = products.map(&:id)
    products_ids_not_found = products_ids.select{ |product_id| products_ids_found.exclude?(product_id) }
    raise ProductsNotFoundException.new(products_ids_not_found) if products_ids_not_found.length > 0
    
    return products
  end
end
