class CreateOrderProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :order_products do |t|
      t.string :product
      t.string :order
      t.integer :quantity
    end
  end
end
