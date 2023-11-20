require 'test_helper'

class CommentChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comment_check = comment_checks(:one)
  end

  test "should get index" do
    get comment_checks_url
    assert_response :success
  end

  test "should get new" do
    get new_comment_check_url
    assert_response :success
  end

  test "should create comment_check" do
    assert_difference('CommentCheck.count') do
      post comment_checks_url, params: { comment_check: {  } }
    end

    assert_redirected_to comment_check_url(CommentCheck.last)
  end

  test "should show comment_check" do
    get comment_check_url(@comment_check)
    assert_response :success
  end

  test "should get edit" do
    get edit_comment_check_url(@comment_check)
    assert_response :success
  end

  test "should update comment_check" do
    patch comment_check_url(@comment_check), params: { comment_check: {  } }
    assert_redirected_to comment_check_url(@comment_check)
  end

  test "should destroy comment_check" do
    assert_difference('CommentCheck.count', -1) do
      delete comment_check_url(@comment_check)
    end

    assert_redirected_to comment_checks_url
  end
end
