class ApplicationController < ActionController::Base

  def index


    20.times do
      key = ['import', 'extract', 'render'].sample
      ProcessLog.create(
        key: key,
        start_time: Time.now - 1000 - (rand * 100),
        end_time: Time.now - (rand * 100)
      )
    end

    redirect_to process_logs_path
  end

end
