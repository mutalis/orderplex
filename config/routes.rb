Rails.application.routes.draw do
  resources :orders
  resources :products
  root 'orders#index'
end

