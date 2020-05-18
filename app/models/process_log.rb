class ProcessLog < ApplicationRecord

  validates :key,         presence: true
  validates :start_time,  presence: true
  validates :status,      presence: true

  before_validation { self.start_time ||= Time.now }
  before_validation { self.status     ||= "Started" }
  before_save       { self.elapsed      = end_time - start_time rescue nil }
  before_save       { self.average_elapsed = ProcessLog.where(id: ProcessLog.where(key: key).where.not(elapsed: nil).where.not(status: "Fail").limit(10).ids).average(:elapsed)}
  after_save        { puts result if $stdout.isatty && completed? && !Rails.env.test? }


  # Methods

  def completed?
    !started?
  end

  def elapsed
    read_attribute(:elapsed) or [(Time.now - start_time).to_i, 86400].min
  end

  # Fail the Process Log.
  # Pass in nothing for no comment or backtrace
  # Pass in the Exception itself to automatically extract.
  # Pass in comment and/or backtrace to set/overwrite.
  def fail!(exception = nil, comment: nil, backtrace: nil)
    self.status = "Fail"
    self.end_time = Time.now

    unless exception.blank?
      self.comment = exception.to_s
      self.backtrace = exception.backtrace.join("\n")
    end

    # Manually passed named arguments overwrite exception if that was also provided.
    self.comment = comment unless comment.blank?
    self.backtrace = Array(backtrace).join("\n") unless backtrace.blank?

    # Send out an Error Email.
    # subject = "Process Failure: #{key} - #{end_time.pretty_local}"
    # message = [subject, self.comment, self.backtrace.try(:nl2br)].compact.join("<hr>")
    # Alert::Mailer.error(message: message, subject: subject).deliver_now
    save!
  end

  def fail?
    status == "Fail"
  end


  def progress
    success? ? 100 : [99, (100 * elapsed / average_elapsed).to_i].min rescue "?"
  end

  def self.progress_of(key)
    return nil if where(key: key).blank?
    log = where(key: key).reorder(id: :desc).first
    [99, (100 * log.elapsed / log.average_elapsed).to_i].min rescue "?"
  end


  def result
    "[#{status}] #{Time.at(elapsed).utc.strftime("%H:%M:%S")} #{self} #{comment.to_s.gsub("\n", '')}"
  end

  def started?
    status == "Started"
  end

  def status
    elapsed >= 86400 ? "Fail" : read_attribute(:status)
  end

  def self.status_of(key)
    return nil if where(key: key).blank?
    where(key: key).reorder(id: :desc).first.try(:status)
  end

  def success!
    self.status = "Success" unless status == "Fail"
    self.end_time = Time.now
    save!
  end

  def success?
    status == "Success"
  end

  def to_s
    key.to_s.smart_titlecase.gsub(":", ": ")
  end

end
