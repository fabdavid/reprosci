require 'test_helper'

class RelTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rel_type = rel_types(:one)
  end

  test "should get index" do
    get rel_types_url
    assert_response :success
  end

  test "should get new" do
    get new_rel_type_url
    assert_response :success
  end

  test "should create rel_type" do
    assert_difference('RelType.count') do
      post rel_types_url, params: { rel_type: {  } }
    end

    assert_redirected_to rel_type_url(RelType.last)
  end

  test "should show rel_type" do
    get rel_type_url(@rel_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_rel_type_url(@rel_type)
    assert_response :success
  end

  test "should update rel_type" do
    patch rel_type_url(@rel_type), params: { rel_type: {  } }
    assert_redirected_to rel_type_url(@rel_type)
  end

  test "should destroy rel_type" do
    assert_difference('RelType.count', -1) do
      delete rel_type_url(@rel_type)
    end

    assert_redirected_to rel_types_url
  end
end
