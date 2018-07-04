Rails.application.routes.draw do
  post '/orders/', to: 'orders#create'
end
