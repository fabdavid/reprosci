require 'test_helper'

class AssertionVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assertion_version = assertion_versions(:one)
  end

  test "should get index" do
    get assertion_versions_url
    assert_response :success
  end

  test "should get new" do
    get new_assertion_version_url
    assert_response :success
  end

  test "should create assertion_version" do
    assert_difference('AssertionVersion.count') do
      post assertion_versions_url, params: { assertion_version: {  } }
    end

    assert_redirected_to assertion_version_url(AssertionVersion.last)
  end

  test "should show assertion_version" do
    get assertion_version_url(@assertion_version)
    assert_response :success
  end

  test "should get edit" do
    get edit_assertion_version_url(@assertion_version)
    assert_response :success
  end

  test "should update assertion_version" do
    patch assertion_version_url(@assertion_version), params: { assertion_version: {  } }
    assert_redirected_to assertion_version_url(@assertion_version)
  end

  test "should destroy assertion_version" do
    assert_difference('AssertionVersion.count', -1) do
      delete assertion_version_url(@assertion_version)
    end

    assert_redirected_to assertion_versions_url
  end
end
