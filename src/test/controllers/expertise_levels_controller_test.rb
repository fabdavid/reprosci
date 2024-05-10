require 'test_helper'

class ExpertiseLevelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @expertise_level = expertise_levels(:one)
  end

  test "should get index" do
    get expertise_levels_url
    assert_response :success
  end

  test "should get new" do
    get new_expertise_level_url
    assert_response :success
  end

  test "should create expertise_level" do
    assert_difference('ExpertiseLevel.count') do
      post expertise_levels_url, params: { expertise_level: {  } }
    end

    assert_redirected_to expertise_level_url(ExpertiseLevel.last)
  end

  test "should show expertise_level" do
    get expertise_level_url(@expertise_level)
    assert_response :success
  end

  test "should get edit" do
    get edit_expertise_level_url(@expertise_level)
    assert_response :success
  end

  test "should update expertise_level" do
    patch expertise_level_url(@expertise_level), params: { expertise_level: {  } }
    assert_redirected_to expertise_level_url(@expertise_level)
  end

  test "should destroy expertise_level" do
    assert_difference('ExpertiseLevel.count', -1) do
      delete expertise_level_url(@expertise_level)
    end

    assert_redirected_to expertise_levels_url
  end
end
