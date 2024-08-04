require 'test_helper'

class ReasonTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reason_type = reason_types(:one)
  end

  test "should get index" do
    get reason_types_url
    assert_response :success
  end

  test "should get new" do
    get new_reason_type_url
    assert_response :success
  end

  test "should create reason_type" do
    assert_difference('ReasonType.count') do
      post reason_types_url, params: { reason_type: {  } }
    end

    assert_redirected_to reason_type_url(ReasonType.last)
  end

  test "should show reason_type" do
    get reason_type_url(@reason_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_reason_type_url(@reason_type)
    assert_response :success
  end

  test "should update reason_type" do
    patch reason_type_url(@reason_type), params: { reason_type: {  } }
    assert_redirected_to reason_type_url(@reason_type)
  end

  test "should destroy reason_type" do
    assert_difference('ReasonType.count', -1) do
      delete reason_type_url(@reason_type)
    end

    assert_redirected_to reason_types_url
  end
end
