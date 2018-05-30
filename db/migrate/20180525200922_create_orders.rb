class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.references :customer
      t.decimal :total_price, precision: 10, scale: 2
    end
  end
end
