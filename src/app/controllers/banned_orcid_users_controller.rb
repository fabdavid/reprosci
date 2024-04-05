class BannedOrcidUsersController < ApplicationController
  before_action :set_banned_orcid_user, only: [:show, :edit, :update, :destroy]

  # GET /banned_orcid_users
  # GET /banned_orcid_users.json
  def index
    @banned_orcid_users = BannedOrcidUser.all
  end

  # GET /banned_orcid_users/1
  # GET /banned_orcid_users/1.json
  def show
  end

  # GET /banned_orcid_users/new
  def new
    @banned_orcid_user = BannedOrcidUser.new
  end

  # GET /banned_orcid_users/1/edit
  def edit
  end

  # POST /banned_orcid_users
  # POST /banned_orcid_users.json
  def create
    @banned_orcid_user = BannedOrcidUser.new(banned_orcid_user_params)

    respond_to do |format|
      if @banned_orcid_user.save
        format.html { redirect_to @banned_orcid_user, notice: 'Banned orcid user was successfully created.' }
        format.json { render :show, status: :created, location: @banned_orcid_user }
      else
        format.html { render :new }
        format.json { render json: @banned_orcid_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /banned_orcid_users/1
  # PATCH/PUT /banned_orcid_users/1.json
  def update
    respond_to do |format|
      if @banned_orcid_user.update(banned_orcid_user_params)
        format.html { redirect_to @banned_orcid_user, notice: 'Banned orcid user was successfully updated.' }
        format.json { render :show, status: :ok, location: @banned_orcid_user }
      else
        format.html { render :edit }
        format.json { render json: @banned_orcid_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /banned_orcid_users/1
  # DELETE /banned_orcid_users/1.json
  def destroy
    @banned_orcid_user.destroy
    respond_to do |format|
      format.html { redirect_to banned_orcid_users_url, notice: 'Banned orcid user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_banned_orcid_user
      @banned_orcid_user = BannedOrcidUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def banned_orcid_user_params
      params.fetch(:banned_orcid_user, {})
    end
end
