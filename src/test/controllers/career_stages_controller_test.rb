require 'test_helper'

class CareerStagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @career_stage = career_stages(:one)
  end

  test "should get index" do
    get career_stages_url
    assert_response :success
  end

  test "should get new" do
    get new_career_stage_url
    assert_response :success
  end

  test "should create career_stage" do
    assert_difference('CareerStage.count') do
      post career_stages_url, params: { career_stage: {  } }
    end

    assert_redirected_to career_stage_url(CareerStage.last)
  end

  test "should show career_stage" do
    get career_stage_url(@career_stage)
    assert_response :success
  end

  test "should get edit" do
    get edit_career_stage_url(@career_stage)
    assert_response :success
  end

  test "should update career_stage" do
    patch career_stage_url(@career_stage), params: { career_stage: {  } }
    assert_redirected_to career_stage_url(@career_stage)
  end

  test "should destroy career_stage" do
    assert_difference('CareerStage.count', -1) do
      delete career_stage_url(@career_stage)
    end

    assert_redirected_to career_stages_url
  end
end
