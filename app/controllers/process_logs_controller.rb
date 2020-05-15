class ProcessLogsController < ApplicationController
  before_action :set_process_log, only: [:show, :edit, :update, :destroy]

  # GET /process_logs
  def index
    @process_logs = ProcessLog.all
  end

  # GET /process_logs/1
  def show
  end

  # GET /process_logs/new
  def new
    @process_log = ProcessLog.new
  end

  # GET /process_logs/1/edit
  def edit
  end

  # POST /process_logs
  def create
    @process_log = ProcessLog.new(process_log_params)

    if @process_log.save
      redirect_to @process_log, notice: 'Process log was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /process_logs/1
  def update
    if @process_log.update(process_log_params)
      redirect_to @process_log, notice: 'Process log was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /process_logs/1
  def destroy
    @process_log.destroy
    redirect_to process_logs_url, notice: 'Process log was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_process_log
      @process_log = ProcessLog.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def process_log_params
      params.require(:process_log).permit(:key, :status, :start_time, :end_time, :elapsed, :average_elapsed, :comment, :backtrace)
    end
end
