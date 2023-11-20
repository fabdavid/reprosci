require 'test_helper'

class AbuseReportTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @abuse_report_type = abuse_report_types(:one)
  end

  test "should get index" do
    get abuse_report_types_url
    assert_response :success
  end

  test "should get new" do
    get new_abuse_report_type_url
    assert_response :success
  end

  test "should create abuse_report_type" do
    assert_difference('AbuseReportType.count') do
      post abuse_report_types_url, params: { abuse_report_type: {  } }
    end

    assert_redirected_to abuse_report_type_url(AbuseReportType.last)
  end

  test "should show abuse_report_type" do
    get abuse_report_type_url(@abuse_report_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_abuse_report_type_url(@abuse_report_type)
    assert_response :success
  end

  test "should update abuse_report_type" do
    patch abuse_report_type_url(@abuse_report_type), params: { abuse_report_type: {  } }
    assert_redirected_to abuse_report_type_url(@abuse_report_type)
  end

  test "should destroy abuse_report_type" do
    assert_difference('AbuseReportType.count', -1) do
      delete abuse_report_type_url(@abuse_report_type)
    end

    assert_redirected_to abuse_report_types_url
  end
end
