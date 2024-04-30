class RelTypesController < ApplicationController
  before_action :set_rel_type, only: [:show, :edit, :update, :destroy]

  # GET /rel_types
  # GET /rel_types.json
  def index
    @rel_types = RelType.all
  end

  # GET /rel_types/1
  # GET /rel_types/1.json
  def show
  end

  # GET /rel_types/new
  def new
    @rel_type = RelType.new
  end

  # GET /rel_types/1/edit
  def edit
  end

  # POST /rel_types
  # POST /rel_types.json
  def create
    @rel_type = RelType.new(rel_type_params)

    respond_to do |format|
      if @rel_type.save
        format.html { redirect_to @rel_type, notice: 'Rel type was successfully created.' }
        format.json { render :show, status: :created, location: @rel_type }
      else
        format.html { render :new }
        format.json { render json: @rel_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rel_types/1
  # PATCH/PUT /rel_types/1.json
  def update
    respond_to do |format|
      if @rel_type.update(rel_type_params)
        format.html { redirect_to @rel_type, notice: 'Rel type was successfully updated.' }
        format.json { render :show, status: :ok, location: @rel_type }
      else
        format.html { render :edit }
        format.json { render json: @rel_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rel_types/1
  # DELETE /rel_types/1.json
  def destroy
    @rel_type.destroy
    respond_to do |format|
      format.html { redirect_to rel_types_url, notice: 'Rel type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rel_type
      @rel_type = RelType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rel_type_params
      params.fetch(:rel_type, {})
    end
end
