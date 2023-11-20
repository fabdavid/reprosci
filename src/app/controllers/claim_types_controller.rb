class ClaimTypesController < ApplicationController
  before_action :set_claim_type, only: [:show, :edit, :update, :destroy]

  # GET /claim_types
  # GET /claim_types.json
  def index
    @claim_types = ClaimType.all
  end

  # GET /claim_types/1
  # GET /claim_types/1.json
  def show
  end

  # GET /claim_types/new
  def new
    @claim_type = ClaimType.new
  end

  # GET /claim_types/1/edit
  def edit
  end

  # POST /claim_types
  # POST /claim_types.json
  def create
    @claim_type = ClaimType.new(claim_type_params)

    respond_to do |format|
      if @claim_type.save
        format.html { redirect_to @claim_type, notice: 'Claim type was successfully created.' }
        format.json { render :show, status: :created, location: @claim_type }
      else
        format.html { render :new }
        format.json { render json: @claim_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /claim_types/1
  # PATCH/PUT /claim_types/1.json
  def update
    respond_to do |format|
      if @claim_type.update(claim_type_params)
        format.html { redirect_to @claim_type, notice: 'Claim type was successfully updated.' }
        format.json { render :show, status: :ok, location: @claim_type }
      else
        format.html { render :edit }
        format.json { render json: @claim_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /claim_types/1
  # DELETE /claim_types/1.json
  def destroy
    @claim_type.destroy
    respond_to do |format|
      format.html { redirect_to claim_types_url, notice: 'Claim type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_claim_type
      @claim_type = ClaimType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def claim_type_params
      params.fetch(:claim_type, {})
    end
end
