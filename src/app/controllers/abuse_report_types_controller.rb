class AbuseReportTypesController < ApplicationController
  before_action :set_abuse_report_type, only: [:show, :edit, :update, :destroy]
  
  # GET /abuse_report_types
  # GET /abuse_report_types.json
  def index
    @abuse_report_types = AbuseReportType.all
  end

  # GET /abuse_report_types/1
  # GET /abuse_report_types/1.json
  def show
  end

  # GET /abuse_report_types/new
  def new
    @abuse_report_type = AbuseReportType.new
  end

  # GET /abuse_report_types/1/edit
  def edit
  end

  # POST /abuse_report_types
  # POST /abuse_report_types.json
  def create
    @abuse_report_type = AbuseReportType.new(abuse_report_type_params)

    respond_to do |format|
      if superadmin? and @abuse_report_type.save
        format.html { redirect_to @abuse_report_type, notice: 'Abuse report type was successfully created.' }
        format.json { render :show, status: :created, location: @abuse_report_type }
      else
        format.html { render :new }
        format.json { render json: @abuse_report_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /abuse_report_types/1
  # PATCH/PUT /abuse_report_types/1.json
  def update
    respond_to do |format|
      if superadmin? and @abuse_report_type.update(abuse_report_type_params)
        format.html { redirect_to @abuse_report_type, notice: 'Abuse report type was successfully updated.' }
        format.json { render :show, status: :ok, location: @abuse_report_type }
      else
        format.html { render :edit }
        format.json { render json: @abuse_report_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /abuse_report_types/1
  # DELETE /abuse_report_types/1.json
  def destroy
    @abuse_report_type.destroy if superadmin?
    respond_to do |format|
      format.html { redirect_to abuse_report_types_url, notice: 'Abuse report type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_abuse_report_type
      @abuse_report_type = AbuseReportType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def abuse_report_type_params
      params.fetch(:abuse_report_type).permit(:name)
    end
end
