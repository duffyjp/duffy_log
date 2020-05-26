module ProcessLogBase
  extend ActiveSupport::Concern

  included do

    # Validations
    validates :key,         presence: true
    validates :start_time,  presence: true
    validates :status,      presence: true

    # Callbacks
    after_initialize  :defaults
    before_save       { self.elapsed          = end_time && end_time - start_time }
    before_save       { self.average_elapsed  = siblings.completed.sorted.limit(10).average(:elapsed) }


    # Scopes
    scope :completed, -> { where.not(elapsed: nil) }
    scope :failed,    -> { where(status: 'Fail') }
    scope :sorted,    -> { order(start_time: :desc) }  # Newest first


    # Methods


    def completed?
      !!read_attribute(:elapsed)
    end

    def elapsed
      super || [(Time.now - start_time).to_i, 86400].min
    rescue
      0 # Prevent an invalid record from causing problems.
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
      self.comment    = comment unless comment.blank?
      self.comment  ||= 'Fail'
      self.backtrace  = Array(backtrace).join("\n") unless backtrace.blank?

      save
    end

    def fail?
      status == "Fail"
    end

    def local_end
      end_time&.localtime&.strftime("%F %-l:%M%P")
    end

    def local_start
      start_time&.localtime&.strftime("%F %-l:%M%P")
    end

    def progress
      success? ? 100 : [99, (100 * elapsed / average_elapsed).to_i].min rescue "?"
    end

    def siblings
      ProcessLog.where(key: key)
    end

    def started?
      status == "Started"
    end

    def status
      elapsed >= 86400 ? "Fail" : super
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
      key.to_s
    end

    private

    # Initialize defaults only on create
    def defaults
      return if persisted?
      self.start_time     ||= Time.now
      self.status         ||= 'Started'
    end

  end
end
