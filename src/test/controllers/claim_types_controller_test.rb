require 'test_helper'

class ClaimTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @claim_type = claim_types(:one)
  end

  test "should get index" do
    get claim_types_url
    assert_response :success
  end

  test "should get new" do
    get new_claim_type_url
    assert_response :success
  end

  test "should create claim_type" do
    assert_difference('ClaimType.count') do
      post claim_types_url, params: { claim_type: {  } }
    end

    assert_redirected_to claim_type_url(ClaimType.last)
  end

  test "should show claim_type" do
    get claim_type_url(@claim_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_claim_type_url(@claim_type)
    assert_response :success
  end

  test "should update claim_type" do
    patch claim_type_url(@claim_type), params: { claim_type: {  } }
    assert_redirected_to claim_type_url(@claim_type)
  end

  test "should destroy claim_type" do
    assert_difference('ClaimType.count', -1) do
      delete claim_type_url(@claim_type)
    end

    assert_redirected_to claim_types_url
  end
end
