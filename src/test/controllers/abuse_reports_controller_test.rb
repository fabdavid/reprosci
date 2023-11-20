require 'test_helper'

class AbuseReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @abuse_report = abuse_reports(:one)
  end

  test "should get index" do
    get abuse_reports_url
    assert_response :success
  end

  test "should get new" do
    get new_abuse_report_url
    assert_response :success
  end

  test "should create abuse_report" do
    assert_difference('AbuseReport.count') do
      post abuse_reports_url, params: { abuse_report: {  } }
    end

    assert_redirected_to abuse_report_url(AbuseReport.last)
  end

  test "should show abuse_report" do
    get abuse_report_url(@abuse_report)
    assert_response :success
  end

  test "should get edit" do
    get edit_abuse_report_url(@abuse_report)
    assert_response :success
  end

  test "should update abuse_report" do
    patch abuse_report_url(@abuse_report), params: { abuse_report: {  } }
    assert_redirected_to abuse_report_url(@abuse_report)
  end

  test "should destroy abuse_report" do
    assert_difference('AbuseReport.count', -1) do
      delete abuse_report_url(@abuse_report)
    end

    assert_redirected_to abuse_reports_url
  end
end
