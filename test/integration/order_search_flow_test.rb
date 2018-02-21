require 'test_helper'

class OrderSearchFlowTest < ActionDispatch::IntegrationTest
  test 'should search by product_id' do
    with_fake_orders do
      product = Product.first
      get "/admin/orders.json?product_id=#{product.id}"
      assert_response :success
      assert_not_nil assigns(:orders)
      assert_equal 10, assigns(:orders).size
    end
  end

  test 'should search with start_at in the past' do
    with_fake_orders do
      start_at = Date.today.beginning_of_day - 2.days
      get "/admin/orders.json?start_at=#{start_at}"
      assert_response :success
      assert_not_nil assigns(:orders)
      assert_equal 30, assigns(:orders).size
    end
  end

  test 'should search with start_at in the future' do
    with_fake_orders do
      start_at = Date.today.beginning_of_day + 2.days
      get "/admin/orders.json?start_at=#{start_at}"
      assert_response :success
      assert_not_nil assigns(:orders)
      assert_equal 0, assigns(:orders).size
    end
  end

  test 'should search with end_at in the past' do
    with_fake_orders do
      end_at = Date.today.beginning_of_day - 2.days
      get "/admin/orders.json?end_at=#{end_at}"
      assert_response :success
      assert_not_nil assigns(:orders)
      assert_equal 0, assigns(:orders).size
    end
  end

  test 'should search with end_at in the future' do
    with_fake_orders do
      end_at = Date.today.beginning_of_day + 2.days
      get "/admin/orders.json?end_at=#{end_at}"
      assert_response :success
      assert_not_nil assigns(:orders)
      assert_equal 30, assigns(:orders).size
    end
  end

  test 'should search with status' do
    with_fake_orders do
      status = 'shipped'
      get "/admin/orders.json?status=#{status}"
      assert_response :success
      assert_not_nil assigns(:orders)
      assert_equal 15, assigns(:orders).size
    end
  end

  test 'should search with all filters' do
    with_fake_orders do
      product = Product.first
      status = 'shipped'
      start_at = Date.today.beginning_of_day - 2.days
      end_at = Date.today.beginning_of_day + 2.days

      get "/admin/orders.json?product_id=#{product.id}&status=#{status}&start_at=#{start_at}&end_at=#{end_at}"
      assert_response :success
      assert_not_nil assigns(:orders)
      assert_equal 5, assigns(:orders).size
    end
  end

  private

  def with_fake_orders(&block)
    product_a = create(:product, name: 'A')
    product_b = create(:product, name: 'B')
    product_c = create(:product, name: 'C')

    assert_equal 3, Product.count

    10.times { Order.process(product_a.id) }
    10.times { Order.process(product_b.id) }
    10.times { Order.process(product_c.id) }

    assert_equal 30, Order.count

    Order.where(product_id: product_a).limit(5).update_all(status: 'shipped')
    Order.where(product_id: product_b).limit(5).update_all(status: 'shipped')
    Order.where(product_id: product_c).limit(5).update_all(status: 'shipped')

    assert_equal 15, Order.where(status: 'shipped').count

    yield block
  end

end
