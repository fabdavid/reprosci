require 'test_helper'

class AssessmentTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assessment_type = assessment_types(:one)
  end

  test "should get index" do
    get assessment_types_url
    assert_response :success
  end

  test "should get new" do
    get new_assessment_type_url
    assert_response :success
  end

  test "should create assessment_type" do
    assert_difference('AssessmentType.count') do
      post assessment_types_url, params: { assessment_type: {  } }
    end

    assert_redirected_to assessment_type_url(AssessmentType.last)
  end

  test "should show assessment_type" do
    get assessment_type_url(@assessment_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_assessment_type_url(@assessment_type)
    assert_response :success
  end

  test "should update assessment_type" do
    patch assessment_type_url(@assessment_type), params: { assessment_type: {  } }
    assert_redirected_to assessment_type_url(@assessment_type)
  end

  test "should destroy assessment_type" do
    assert_difference('AssessmentType.count', -1) do
      delete assessment_type_url(@assessment_type)
    end

    assert_redirected_to assessment_types_url
  end
end
