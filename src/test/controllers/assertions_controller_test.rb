require 'test_helper'

class AssertionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assertion = assertions(:one)
  end

  test "should get index" do
    get assertions_url
    assert_response :success
  end

  test "should get new" do
    get new_assertion_url
    assert_response :success
  end

  test "should create assertion" do
    assert_difference('Assertion.count') do
      post assertions_url, params: { assertion: {  } }
    end

    assert_redirected_to assertion_url(Assertion.last)
  end

  test "should show assertion" do
    get assertion_url(@assertion)
    assert_response :success
  end

  test "should get edit" do
    get edit_assertion_url(@assertion)
    assert_response :success
  end

  test "should update assertion" do
    patch assertion_url(@assertion), params: { assertion: {  } }
    assert_redirected_to assertion_url(@assertion)
  end

  test "should destroy assertion" do
    assert_difference('Assertion.count', -1) do
      delete assertion_url(@assertion)
    end

    assert_redirected_to assertions_url
  end
end
