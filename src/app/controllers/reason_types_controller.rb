class ReasonTypesController < ApplicationController
  before_action :set_reason_type, only: %i[ show edit update destroy ]

  # GET /reason_types or /reason_types.json
  def index
    @reason_types = ReasonType.all
  end

  # GET /reason_types/1 or /reason_types/1.json
  def show
  end

  # GET /reason_types/new
  def new
    @reason_type = ReasonType.new
  end

  # GET /reason_types/1/edit
  def edit
  end

  # POST /reason_types or /reason_types.json
  def create
    @reason_type = ReasonType.new(reason_type_params)

    respond_to do |format|
      if admin? and @reason_type.save
        format.html { redirect_to reason_type_url(@reason_type), notice: "Reason type was successfully created." }
        format.json { render :show, status: :created, location: @reason_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reason_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reason_types/1 or /reason_types/1.json
  def update
    respond_to do |format|
      if admin? and @reason_type.update(reason_type_params)
        format.html { redirect_to reason_type_url(@reason_type), notice: "Reason type was successfully updated." }
        format.json { render :show, status: :ok, location: @reason_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reason_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reason_types/1 or /reason_types/1.json
  def destroy
    @reason_type.destroy if admin?

    respond_to do |format|
      format.html { redirect_to reason_types_url, notice: "Reason type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reason_type
      @reason_type = ReasonType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def reason_type_params
      params.fetch(:reason_type).permit(:name)
    end
end
