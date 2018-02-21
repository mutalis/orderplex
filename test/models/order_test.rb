require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  # NB: we can't use transactional fixtures when testing code that manually manages a
  # transaction, so we turn them off for this test, but that means we also need to
  # clean up the database after each test manually, which we do using the
  # DatabaseCleaner gem.
  #
  self.use_transactional_fixtures = false

  def setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  def teardown
    # ::ActiveRecord::Base.establish_connection
    DatabaseCleaner.clean
  end

  test 'should process concurrent orders with low stock' do
    product = create(:product, stock: 1)

    assert_difference 'Order.count', 1 do
      assert_raises OutOfStockError do
        ::ActiveRecord::Base.clear_all_connections!

        # simultaneously process an order in two separate processes to simulate
        # concurrent requests
        Parallel.map([1, 2]) do |i|
          ::ActiveRecord::Base.retrieve_connection
          Order.process(product.id)
        end
      end
    end

    assert_equal 0, product.reload.stock
  end

  test 'should process concurrent orders with ample stock' do
    product = create(:product, stock: 3)

    assert_difference 'Order.count', 2 do
      ::ActiveRecord::Base.clear_all_connections!
      Parallel.map([1, 2]) do |i|
        ::ActiveRecord::Base.retrieve_connection
        Order.process(product.id)
      end
    end

    assert_equal 1, product.reload.stock
  end

  test 'should get shipping status' do
    product = create(:product, stock: 1)
    order = Order.process(product.id)
    order.update(fedex_id: '198yGaAf074')
    body = JSON.dump({status: 'shipped'})
    url = "https://fedex.com/api/shipping/status?id=#{order.fedex_id}"

    mock(HTTP).get(url) { HTTP::Response.new(body: body, version: 2, status: 200) }
    assert_equal 'shipped', order.get_shipping_status
  end

end
