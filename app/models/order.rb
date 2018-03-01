class Order < ActiveRecord::Base
  belongs_to :product

  after_create do
    UpdateShippingStatusJob.perform_later(self)
  end
end
