Product.destroy_all
Customer.destroy_all
OrderProduct.destroy_all
Order.destroy_all

Product.create!([
  { name: 'iPhone 8', price: 700.0 },
  { name: 'iPhone X', price: 1099.0 },
  { name: 'Galaxy S9', price: 799.0 },
  { name: 'Galaxy S9 Plus', price: 899.0 },
])

Customer.create!([
  { name: 'John' },
  { name: 'Mary' },
])
