require 'test_helper'

class SeriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @series = series(:one)
  end

  test "should get index" do
    get series_index_url
    assert_response :success
  end

  test "should get new" do
    get new_series_url
    assert_response :success
  end

  test "should destroy series" do
    assert_difference('Series.count', -1) do
      delete series_url(@series)
    end

    assert_redirected_to series_index_url
  end
end
