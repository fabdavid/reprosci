class ReasonsController < ApplicationController
  before_action :set_reason, only: %i[ show edit update destroy ]

  # GET /reasons or /reasons.json
  def index
    if read_admin?
      @reasons = Reason.all
    else
      @reasons = []
    end
  end

  # GET /reasons/1 or /reasons/1.json
  def show
  end

  # GET /reasons/new
  def new
    @reason = Reason.new
  end

  # GET /reasons/1/edit
  def edit
  end

  # POST /reasons or /reasons.json
  def create
    @reason = Reason.new(reason_params)

    respond_to do |format|
      if read_admin? and @reason.save
        format.html {
          #redirect_to reason_url(@reason), notice: "Reason was successfully created."
#          render :partial => "update"
        }
        format.json { render :show, status: :created, location: @reason }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reason.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reasons/1 or /reasons/1.json
  def update

    @reason.user_id = current_user.id
    respond_to do |format|
      if read_admin? and @reason.update(reason_params)
        format.html {
          
          #redirect_to reason_url(@reason), notice: "Reason was successfully updated."
          render :partial => "update"
        }
        format.json { render :show, status: :ok, location: @reason }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reason.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reasons/1 or /reasons/1.json
  def destroy
    @reason.destroy if read_admin?

    respond_to do |format|
      format.html { redirect_to reasons_url, notice: "Reason was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reason
      @reason = Reason.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def reason_params
      params.fetch(:reason).permit(:reason_type_ids)
    end
end
