class CareerStagesController < ApplicationController
  before_action :set_career_stage, only: %i[ show edit update destroy ]

  # GET /career_stages or /career_stages.json
  def index
    @career_stages = CareerStage.all
  end

  # GET /career_stages/1 or /career_stages/1.json
  def show
  end

  # GET /career_stages/new
  def new
    @career_stage = CareerStage.new
  end

  # GET /career_stages/1/edit
  def edit
  end

  # POST /career_stages or /career_stages.json
  def create
    @career_stage = CareerStage.new(career_stage_params)

    respond_to do |format|
      if @career_stage.save
        format.html { redirect_to career_stage_url(@career_stage), notice: "Career stage was successfully created." }
        format.json { render :show, status: :created, location: @career_stage }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @career_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /career_stages/1 or /career_stages/1.json
  def update
    respond_to do |format|
      if @career_stage.update(career_stage_params)
        format.html { redirect_to career_stage_url(@career_stage), notice: "Career stage was successfully updated." }
        format.json { render :show, status: :ok, location: @career_stage }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @career_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /career_stages/1 or /career_stages/1.json
  def destroy
    @career_stage.destroy

    respond_to do |format|
      format.html { redirect_to career_stages_url, notice: "Career stage was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_career_stage
      @career_stage = CareerStage.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def career_stage_params
      params.fetch(:career_stage).permit(:name)
    end
end
