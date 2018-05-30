class CreateOrderProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :order_products do |t|
      t.references :product
      t.references :order
      t.integer :quantity
    end
  end
end
