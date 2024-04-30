class AssertionTypesController < ApplicationController
  before_action :set_assertion_type, only: [:show, :edit, :update, :destroy]

  # GET /assertion_types
  # GET /assertion_types.json
  def index
    @assertion_types = AssertionType.all
  end

  # GET /assertion_types/1
  # GET /assertion_types/1.json
  def show
  end

  # GET /assertion_types/new
  def new
    @assertion_type = AssertionType.new
  end

  # GET /assertion_types/1/edit
  def edit
  end

  # POST /assertion_types
  # POST /assertion_types.json
  def create
    @assertion_type = AssertionType.new(assertion_type_params)

    respond_to do |format|
      if @assertion_type.save
        format.html { redirect_to @assertion_type, notice: 'Assertion type was successfully created.' }
        format.json { render :show, status: :created, location: @assertion_type }
      else
        format.html { render :new }
        format.json { render json: @assertion_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assertion_types/1
  # PATCH/PUT /assertion_types/1.json
  def update
    respond_to do |format|
      if @assertion_type.update(assertion_type_params)
        format.html { redirect_to @assertion_type, notice: 'Assertion type was successfully updated.' }
        format.json { render :show, status: :ok, location: @assertion_type }
      else
        format.html { render :edit }
        format.json { render json: @assertion_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assertion_types/1
  # DELETE /assertion_types/1.json
  def destroy
    @assertion_type.destroy
    respond_to do |format|
      format.html { redirect_to assertion_types_url, notice: 'Assertion type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assertion_type
      @assertion_type = AssertionType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assertion_type_params
      params.fetch(:assertion_type, {})
    end
end
