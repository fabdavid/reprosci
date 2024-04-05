require 'test_helper'

class WorkspaceOrcidUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @workspace_orcid_user = workspace_orcid_users(:one)
  end

  test "should get index" do
    get workspace_orcid_users_url
    assert_response :success
  end

  test "should get new" do
    get new_workspace_orcid_user_url
    assert_response :success
  end

  test "should create workspace_orcid_user" do
    assert_difference('WorkspaceOrcidUser.count') do
      post workspace_orcid_users_url, params: { workspace_orcid_user: {  } }
    end

    assert_redirected_to workspace_orcid_user_url(WorkspaceOrcidUser.last)
  end

  test "should show workspace_orcid_user" do
    get workspace_orcid_user_url(@workspace_orcid_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_workspace_orcid_user_url(@workspace_orcid_user)
    assert_response :success
  end

  test "should update workspace_orcid_user" do
    patch workspace_orcid_user_url(@workspace_orcid_user), params: { workspace_orcid_user: {  } }
    assert_redirected_to workspace_orcid_user_url(@workspace_orcid_user)
  end

  test "should destroy workspace_orcid_user" do
    assert_difference('WorkspaceOrcidUser.count', -1) do
      delete workspace_orcid_user_url(@workspace_orcid_user)
    end

    assert_redirected_to workspace_orcid_users_url
  end
end
