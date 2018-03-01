class UpdateShippingStatusJob < ActiveJob::Base
  queue_as :default

  def perform(order)
    # Store the shipment id in the order.
    if (order.status == 'Processing') && (order.shipment_id == nil)
      shipment = Fedex::Shipment.create
      order.shipment_id = shipment.id
      order.save!
    else # Updates the order status
      shipment = Fedex::Shipment.find(order.shipment_id.to_i)
      order.status = shipment.status
      order.save!
    end
  end
end
