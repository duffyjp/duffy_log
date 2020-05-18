require 'rails_helper'

RSpec.describe ProcessLog, type: :model do

  it "validates you have a key" do
    process_log = build :process_log, key: nil
    expect(process_log.save).to eq(false)
  end

  it "The start time you specify is used" do
    time = Time.now.midnight
    process_log = create :process_log, start_time: time
    expect(process_log.reload.start_time).to eq(time)
  end

  it "The start time is implied to be Time.now", :buggy do
    process_log = create :process_log
    expect(process_log.reload.start_time.between?(Time.now - 1.second, Time.now + 1.second)).to eq(true)
  end

  it "Time elapsed is automatically calculated" do
    process_log = create :process_log, start_time: Time.now.midnight, end_time: Time.now.midnight + 1.minute
    expect(process_log.reload.elapsed).to eq(60)
  end

  it "average_elapsed takes an average of the last 10 non-Fail results for the same key" do
    10.times{ create(:process_log, :success) }
    expect(create(:process_log, :success).average_elapsed).to be_between(0, 3600)
  end

  describe "status" do

    it "is 'Started' if not otherwise specified" do
      process_log = create :process_log
      expect(process_log.reload.status).to eq("Started")
    end

    it "is 'Success' if success! is called before any failure" do
      process_log = create :process_log
      process_log.success!
      expect(process_log.reload.status).to eq("Success")
    end

    it "is 'Fail' if fail! is called" do
      process_log = create :process_log
      process_log.fail!
      expect(process_log.reload.status).to eq("Fail")
    end

    it "is 'Fail' if fail! is called, even if success! was already called (shouldn't really happen)" do
      process_log = create :process_log
      process_log.success!
      process_log.fail!
      expect(process_log.reload.status).to eq("Fail")
    end

    it ".fail? should return true if failed" do
      process_log = create :process_log
      process_log.fail!
      expect(process_log.reload.fail?).to eq(true)
    end

    it ".fail? should return false if success" do
      process_log = create :process_log
      process_log.success!
      expect(process_log.reload.fail?).to eq(false)
    end

    it ".fail? should return false if started" do
      process_log = create :process_log
      expect(process_log.reload.fail?).to eq(false)
    end

    it ".started? should return true if started" do
      process_log = create :process_log
      expect(process_log.reload.started?).to eq(true)
    end

    it ".started? should return false if finished" do
      process_log = create :process_log
      process_log.success!
      expect(process_log.reload.started?).to eq(false)
    end

    it ".success? should return true if success" do
      process_log = create :process_log
      process_log.success!
      expect(process_log.reload.success?).to eq(true)
    end

    it "itself should return Fail if for zombie processes (24hr or more)" do
      process_log = create :process_log, start_time: Time.now - 25.hours
      expect(process_log.reload.status).to eq("Fail")
    end

    it "itself should return whatever is in the column for normal records" do
      process_log = create :process_log
      process_log.fail!
      expect(process_log.reload.status).to eq("Fail")
    end
  end

  it "progress shows the estimated percent complete" do
    allow_any_instance_of(ProcessLog).to receive(:elapsed).and_return 60
    process_log = create :process_log
    process_log.update_columns(average_elapsed: 120)  # That was annoying.
    expect(process_log.reload.progress).to eq(50)
  end

  describe "[CLASS METHODS]" do

    it "progress_of(key) shows the progress of the newest process_log matching the key specified" do
      allow_any_instance_of(ProcessLog).to receive(:elapsed).and_return 60
      allow_any_instance_of(ProcessLog).to receive(:average_elapsed).and_return 120
      create :process_log, key: "foo"
      expect(ProcessLog.progress_of("foo")).to eq(50)
    end

    it "progress_of(key) shows the 99% progress for processes taking longer than normal" do
      allow_any_instance_of(ProcessLog).to receive(:elapsed).and_return 60
      allow_any_instance_of(ProcessLog).to receive(:average_elapsed).and_return 30
      create :process_log, key: "foo"
      expect(ProcessLog.progress_of("foo")).to eq(99)
    end

    it "progress_of returns '?' when the key exists, but average_elapsed isn't known is found" do
      create :process_log, key: "wisconsin"
      expect(ProcessLog.progress_of("wisconsin")).to eq("?")
    end


    it "progress_of returns nil if key isn't found" do
      expect(ProcessLog.progress_of("asdfasdf")).to eq nil
      expect(ProcessLog.progress_of("asdfasdf")).to eq nil
    end

    it "status_of returns the status of the newest process log matching the key given" do
      create :process_log, key: "import"
      expect(ProcessLog.status_of("import")).to eq("Started")
    end

  end
end
