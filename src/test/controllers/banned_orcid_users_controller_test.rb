require 'test_helper'

class BannedOrcidUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @banned_orcid_user = banned_orcid_users(:one)
  end

  test "should get index" do
    get banned_orcid_users_url
    assert_response :success
  end

  test "should get new" do
    get new_banned_orcid_user_url
    assert_response :success
  end

  test "should create banned_orcid_user" do
    assert_difference('BannedOrcidUser.count') do
      post banned_orcid_users_url, params: { banned_orcid_user: {  } }
    end

    assert_redirected_to banned_orcid_user_url(BannedOrcidUser.last)
  end

  test "should show banned_orcid_user" do
    get banned_orcid_user_url(@banned_orcid_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_banned_orcid_user_url(@banned_orcid_user)
    assert_response :success
  end

  test "should update banned_orcid_user" do
    patch banned_orcid_user_url(@banned_orcid_user), params: { banned_orcid_user: {  } }
    assert_redirected_to banned_orcid_user_url(@banned_orcid_user)
  end

  test "should destroy banned_orcid_user" do
    assert_difference('BannedOrcidUser.count', -1) do
      delete banned_orcid_user_url(@banned_orcid_user)
    end

    assert_redirected_to banned_orcid_users_url
  end
end
