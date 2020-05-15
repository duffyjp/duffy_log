require "application_system_test_case"

class ProcessLogsTest < ApplicationSystemTestCase
  setup do
    @process_log = process_logs(:one)
  end

  test "visiting the index" do
    visit process_logs_url
    assert_selector "h1", text: "Process Logs"
  end

  test "creating a Process log" do
    visit process_logs_url
    click_on "New Process Log"

    fill_in "Average elapsed", with: @process_log.average_elapsed
    fill_in "Backtrace", with: @process_log.backtrace
    fill_in "Comment", with: @process_log.comment
    fill_in "Elapsed", with: @process_log.elapsed
    fill_in "End time", with: @process_log.end_time
    fill_in "Key", with: @process_log.key
    fill_in "Start time", with: @process_log.start_time
    fill_in "Status", with: @process_log.status
    click_on "Create Process log"

    assert_text "Process log was successfully created"
    click_on "Back"
  end

  test "updating a Process log" do
    visit process_logs_url
    click_on "Edit", match: :first

    fill_in "Average elapsed", with: @process_log.average_elapsed
    fill_in "Backtrace", with: @process_log.backtrace
    fill_in "Comment", with: @process_log.comment
    fill_in "Elapsed", with: @process_log.elapsed
    fill_in "End time", with: @process_log.end_time
    fill_in "Key", with: @process_log.key
    fill_in "Start time", with: @process_log.start_time
    fill_in "Status", with: @process_log.status
    click_on "Update Process log"

    assert_text "Process log was successfully updated"
    click_on "Back"
  end

  test "destroying a Process log" do
    visit process_logs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Process log was successfully destroyed"
  end
end
