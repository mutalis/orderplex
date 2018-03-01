json.extract! order, :id, :customer_name, :status, :product_id, :created_at, :updated_at
json.url order_url(order, format: :json)
