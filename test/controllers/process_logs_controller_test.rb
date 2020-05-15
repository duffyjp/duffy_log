require 'test_helper'

class ProcessLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @process_log = process_logs(:one)
  end

  test "should get index" do
    get process_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_process_log_url
    assert_response :success
  end

  test "should create process_log" do
    assert_difference('ProcessLog.count') do
      post process_logs_url, params: { process_log: { average_elapsed: @process_log.average_elapsed, backtrace: @process_log.backtrace, comment: @process_log.comment, elapsed: @process_log.elapsed, end_time: @process_log.end_time, key: @process_log.key, start_time: @process_log.start_time, status: @process_log.status } }
    end

    assert_redirected_to process_log_url(ProcessLog.last)
  end

  test "should show process_log" do
    get process_log_url(@process_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_process_log_url(@process_log)
    assert_response :success
  end

  test "should update process_log" do
    patch process_log_url(@process_log), params: { process_log: { average_elapsed: @process_log.average_elapsed, backtrace: @process_log.backtrace, comment: @process_log.comment, elapsed: @process_log.elapsed, end_time: @process_log.end_time, key: @process_log.key, start_time: @process_log.start_time, status: @process_log.status } }
    assert_redirected_to process_log_url(@process_log)
  end

  test "should destroy process_log" do
    assert_difference('ProcessLog.count', -1) do
      delete process_log_url(@process_log)
    end

    assert_redirected_to process_logs_url
  end
end
