require 'rails_helper'
include ActiveSupport::Testing::TimeHelpers


RSpec.describe ProcessLog, type: :model do
  let(:process_log) { create :process_log }

  context '[VALIDATIONS]' do
    it "validates presence of key" do
      process_log.key = nil
      expect{ process_log.save! }.to raise_error /Key can't be blank/
    end

    it "start_time can't be blank" do
      process_log.update(start_time: nil)
      expect{ process_log.save! }.to raise_error /Start time can't be blank/
    end

    it "status can't be blank" do
      process_log.update(status: nil)
      expect{ process_log.save! }.to raise_error /Status can't be blank/
    end
  end

  context '[INSTANCE METHODS]' do

    describe 'completed?' do
      it 'returns true if elapsed is set' do
        process_log.success!
        expect(process_log.read_attribute(:elapsed)).to_not eq nil
        expect(process_log.completed?).to eq true
      end

      it 'returns false if elapsed is unset' do
        expect(process_log.read_attribute(:elapsed)).to eq nil
        expect(process_log.completed?).to eq false
      end
    end

    describe 'elapsed' do
      it "is automatically calculated" do
        process_log = create :process_log, start_time: Time.now.midnight, end_time: Time.now.midnight + 1.minute
        expect(process_log.reload.elapsed).to eq(60)
      end

      it "returns a live time since start if unset" do
        process_log = create :process_log, start_time: Time.now - 1.hour
        expect(process_log.reload.elapsed).to be_between(3600, 3610)
      end

      it "returns stops at one day for incomplete logs" do
        process_log = create :process_log, start_time: Time.now - 2.days
        expect(process_log.reload.elapsed).to eq 86400
      end
    end

    describe 'fail!' do

      it 'marks the status as "Fail"' do
        process_log.fail!
        expect(process_log.status).to eq "Fail"
      end

      it "will mark status 'Fail' even if already set to Success" do
        process_log.success!
        process_log.fail!
        expect(process_log.reload.status).to eq("Fail")
      end

      it "will record passed in exception information" do
        begin
          0/0
        rescue StandardError => e
          process_log.fail!(e)
        end
        expect(process_log.reload.comment).to eq "divided by 0"
        expect(process_log.reload.backtrace).to include 'spec/models/process_log_spec.rb'
      end

      it "will record comments passed as named parameter" do
        process_log.fail!(comment: "Fatal Exception 0E")
        expect(process_log.reload.comment).to eq "Fatal Exception 0E"
      end

      it "will record backtrace passed as named parameter" do
        process_log.fail!(backtrace: "Windows 95")
        expect(process_log.reload.backtrace).to eq "Windows 95"
      end

      it "comment will be 'Fail' if no exception or comment param passed" do
        process_log.fail!
        expect(process_log.reload.comment).to eq "Fail"
      end
    end

    describe 'fail?' do
      it "returns true for failed" do
        process_log.fail!
        expect(process_log.reload.fail?).to eq(true)
      end

      it "returns false for success" do
        process_log.success!
        expect(process_log.reload.fail?).to eq(false)
      end

      it "returns false if incomplete" do
        expect(process_log.reload.fail?).to eq(false)
      end
    end


    it 'local_end returns local human readable timestamp' do
      travel_to Time.new(2004, 11, 24, 1, 4) do
        process_log.success!
        expect(process_log.local_end).to eq '2004-11-24 1:04am'
      end
    end

    it 'local_start returns local human readable timestamp' do
      travel_to Time.new(2001, 2, 3, 4, 5, 6) do
        process_log.success!
        expect(process_log.local_start).to eq "2001-02-03 4:05am"
      end
    end

    it "progress shows the estimated percent complete" do
      allow_any_instance_of(ProcessLog).to receive(:elapsed).and_return 60
      process_log.update_columns(average_elapsed: 120)
      expect(process_log.reload.progress).to eq(50)
    end

    it "progress returns 100 for completed logs" do
      process_log.success!
      expect(process_log.reload.progress).to eq(100)
    end

    it 'siblings returns logs with the same key (including self)' do
      process_log2 = create :process_log
      expect(process_log.siblings).to include process_log
      expect(process_log.siblings).to include process_log2
    end

    describe 'started?' do
      it 'returns true if started' do
        expect(process_log.started?).to eq true
      end

      it 'returns false if completed' do
        process_log.fail!
        expect(process_log.started?).to eq false
      end
    end

    describe "status" do

      it "is 'Started' if not otherwise specified" do
        expect(process_log.reload.status).to eq("Started")
      end

      it "is 'Success' if success! is called before any failure" do
        process_log.success!
        expect(process_log.reload.status).to eq("Success")
      end
    end

    describe 'success!' do
      it 'sets the :status and :end_time' do
        process_log.success!
        expect(process_log.status).to eq "Success"
        expect(process_log.end_time).to_not eq nil
      end

      it "doesn't override a Fail" do
        process_log.fail!
        process_log.success!
        expect(process_log.status).to eq "Fail"
      end
    end

    describe 'success?' do
      it 'returns true if successful' do
        process_log.success!
        expect(process_log.success?).to eq true
      end

      it 'returns false if failed' do
        process_log.fail!
        expect(process_log.success?).to eq false
      end
    end

    it "to_s returns the key" do
      expect(process_log.to_s).to eq "import"
    end

  end

end
