# workshop-architecture

## Stack
- [Ruby](https://www.ruby-lang.org/en/)
- [Ruby on Rails](https://rubyonrails.org/)
- [RSpec](http://rspec.info/)
- [Postgres](https://www.postgresql.org/)

## Goal
Demonstrate how to start a project following good principles of architecture.

Follow the steps above:

### Create an use case to create a new order
1. Inputs: customer (customer_id), product list (product_id, quantity)
1. Outputs: success (when everythings is ok returns order_id and total_price), error (when customer or product doesn't exists)
1. Implement customer gateway database
1. Implement product gateway database
1. Implement order gateway database
1. Implement order presenter to response in JSON

### Create an use case to show all orders by customer
1. Inputs: customer (customer_id)
1. Outputs: success (when everythings is ok returns a list of orders with order_id, products and total price), error (when customer doesn't exists)
1. Extract business logic to an order entity
1. Implement order gateway database
1. Implement show orders presenter to response in JSON

### Delivery mechanism
1. Create a order controller

### Evolving the project
1. Create show orders presenter to response in CSV
1. Create show orders gateway to consume an API REST

# Starting

```sh
docker-compose up
docker-compose run web rake db:create
docker-compose run web rake db:migrate
```

