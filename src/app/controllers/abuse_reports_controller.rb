class AbuseReportsController < ApplicationController
  before_action :set_abuse_report, only: [:show, :edit, :update, :destroy]

  # GET /abuse_reports
  # GET /abuse_reports.json
  def index
    @abuse_reports = AbuseReport.all
  end

  # GET /abuse_reports/1
  # GET /abuse_reports/1.json
  def show
  end

  # GET /abuse_reports/new
  def new
    @abuse_report = AbuseReport.new
  end

  # GET /abuse_reports/1/edit
  def edit
  end

  # POST /abuse_reports
  # POST /abuse_reports.json
  def create
    @abuse_report = AbuseReport.new(abuse_report_params)

    respond_to do |format|
      if @abuse_report.save
        format.html { redirect_to @abuse_report, notice: 'Abuse report was successfully created.' }
        format.json { render :show, status: :created, location: @abuse_report }
      else
        format.html { render :new }
        format.json { render json: @abuse_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /abuse_reports/1
  # PATCH/PUT /abuse_reports/1.json
  def update
    respond_to do |format|
      if @abuse_report.update(abuse_report_params)
        format.html { redirect_to @abuse_report, notice: 'Abuse report was successfully updated.' }
        format.json { render :show, status: :ok, location: @abuse_report }
      else
        format.html { render :edit }
        format.json { render json: @abuse_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /abuse_reports/1
  # DELETE /abuse_reports/1.json
  def destroy
    @abuse_report.destroy
    respond_to do |format|
      format.html { redirect_to abuse_reports_url, notice: 'Abuse report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_abuse_report
      @abuse_report = AbuseReport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def abuse_report_params
      params.fetch(:abuse_report, {})
    end
end
