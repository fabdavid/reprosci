require 'test_helper'

class AssertionTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assertion_type = assertion_types(:one)
  end

  test "should get index" do
    get assertion_types_url
    assert_response :success
  end

  test "should get new" do
    get new_assertion_type_url
    assert_response :success
  end

  test "should create assertion_type" do
    assert_difference('AssertionType.count') do
      post assertion_types_url, params: { assertion_type: {  } }
    end

    assert_redirected_to assertion_type_url(AssertionType.last)
  end

  test "should show assertion_type" do
    get assertion_type_url(@assertion_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_assertion_type_url(@assertion_type)
    assert_response :success
  end

  test "should update assertion_type" do
    patch assertion_type_url(@assertion_type), params: { assertion_type: {  } }
    assert_redirected_to assertion_type_url(@assertion_type)
  end

  test "should destroy assertion_type" do
    assert_difference('AssertionType.count', -1) do
      delete assertion_type_url(@assertion_type)
    end

    assert_redirected_to assertion_types_url
  end
end
