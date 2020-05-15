class ApplicationController < ActionController::Base

  def index
    redirect_to process_logs_path
  end

end
