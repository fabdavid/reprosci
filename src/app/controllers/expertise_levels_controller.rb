class ExpertiseLevelsController < ApplicationController
  before_action :set_expertise_level, only: %i[ show edit update destroy ]

  # GET /expertise_levels or /expertise_levels.json
  def index
    @expertise_levels = ExpertiseLevel.all
  end

  # GET /expertise_levels/1 or /expertise_levels/1.json
  def show
  end

  # GET /expertise_levels/new
  def new
    @expertise_level = ExpertiseLevel.new
  end

  # GET /expertise_levels/1/edit
  def edit
  end

  # POST /expertise_levels or /expertise_levels.json
  def create
    @expertise_level = ExpertiseLevel.new(expertise_level_params)

    respond_to do |format|
      if admin? and @expertise_level.save
        format.html { redirect_to expertise_level_url(@expertise_level), notice: "Expertise level was successfully created." }
        format.json { render :show, status: :created, location: @expertise_level }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @expertise_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expertise_levels/1 or /expertise_levels/1.json
  def update
    respond_to do |format|
      if admin? and @expertise_level.update(expertise_level_params)
        format.html { redirect_to expertise_level_url(@expertise_level), notice: "Expertise level was successfully updated." }
        format.json { render :show, status: :ok, location: @expertise_level }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @expertise_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expertise_levels/1 or /expertise_levels/1.json
  def destroy
    @expertise_level.destroy if admin?

    respond_to do |format|
      format.html { redirect_to expertise_levels_url, notice: "Expertise level was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expertise_level
      @expertise_level = ExpertiseLevel.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def expertise_level_params
      params.fetch(:expertise_level).permit(:name)
    end
end
