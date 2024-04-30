class AssertionVersionsController < ApplicationController
  before_action :set_assertion_version, only: [:show, :edit, :update, :destroy]

  # GET /assertion_versions
  # GET /assertion_versions.json
  def index
    @assertion_versions = AssertionVersion.all
  end

  # GET /assertion_versions/1
  # GET /assertion_versions/1.json
  def show
  end

  # GET /assertion_versions/new
  def new
    @assertion_version = AssertionVersion.new
  end

  # GET /assertion_versions/1/edit
  def edit
  end

  # POST /assertion_versions
  # POST /assertion_versions.json
  def create
    @assertion_version = AssertionVersion.new(assertion_version_params)

    respond_to do |format|
      if @assertion_version.save
        format.html { redirect_to @assertion_version, notice: 'Assertion version was successfully created.' }
        format.json { render :show, status: :created, location: @assertion_version }
      else
        format.html { render :new }
        format.json { render json: @assertion_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assertion_versions/1
  # PATCH/PUT /assertion_versions/1.json
  def update
    respond_to do |format|
      if @assertion_version.update(assertion_version_params)
        format.html { redirect_to @assertion_version, notice: 'Assertion version was successfully updated.' }
        format.json { render :show, status: :ok, location: @assertion_version }
      else
        format.html { render :edit }
        format.json { render json: @assertion_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assertion_versions/1
  # DELETE /assertion_versions/1.json
  def destroy
    @assertion_version.destroy
    respond_to do |format|
      format.html { redirect_to assertion_versions_url, notice: 'Assertion version was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assertion_version
      @assertion_version = AssertionVersion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assertion_version_params
      params.fetch(:assertion_version, {})
    end
end
