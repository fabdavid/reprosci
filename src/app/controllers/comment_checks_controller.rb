class CommentChecksController < ApplicationController
  before_action :set_comment_check, only: [:show, :edit, :update, :destroy]

  # GET /comment_checks
  # GET /comment_checks.json
  def index
    @comment_checks = CommentCheck.all
  end

  # GET /comment_checks/1
  # GET /comment_checks/1.json
  def show
  end

  # GET /comment_checks/new
  def new
    @comment_check = CommentCheck.new
  end

  # GET /comment_checks/1/edit
  def edit
  end

  # POST /comment_checks
  # POST /comment_checks.json
  def create
    @comment_check = CommentCheck.new(comment_check_params)

    respond_to do |format|
      if @comment_check.save
        format.html { redirect_to @comment_check, notice: 'Comment check was successfully created.' }
        format.json { render :show, status: :created, location: @comment_check }
      else
        format.html { render :new }
        format.json { render json: @comment_check.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comment_checks/1
  # PATCH/PUT /comment_checks/1.json
  def update
    respond_to do |format|
      if @comment_check.update(comment_check_params)
        format.html { redirect_to @comment_check, notice: 'Comment check was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment_check }
      else
        format.html { render :edit }
        format.json { render json: @comment_check.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comment_checks/1
  # DELETE /comment_checks/1.json
  def destroy
    @comment_check.destroy
    respond_to do |format|
      format.html { redirect_to comment_checks_url, notice: 'Comment check was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment_check
      @comment_check = CommentCheck.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_check_params
      params.fetch(:comment_check, {})
    end
end
