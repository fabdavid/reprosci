class WorkspaceOrcidUsersController < ApplicationController
  before_action :set_workspace_orcid_user, only: [:show, :edit, :update, :destroy]

  # GET /workspace_orcid_users
  # GET /workspace_orcid_users.json
  def index
    @workspace_orcid_users = WorkspaceOrcidUser.all
  end

  # GET /workspace_orcid_users/1
  # GET /workspace_orcid_users/1.json
  def show
  end

  # GET /workspace_orcid_users/new
  def new
    @workspace_orcid_user = WorkspaceOrcidUser.new
  end

  # GET /workspace_orcid_users/1/edit
  def edit
  end

  # POST /workspace_orcid_users
  # POST /workspace_orcid_users.json
  def create
    @workspace_orcid_user = WorkspaceOrcidUser.new(workspace_orcid_user_params)

    respond_to do |format|
      if @workspace_orcid_user.save
        format.html { redirect_to @workspace_orcid_user, notice: 'Workspace orcid user was successfully created.' }
        format.json { render :show, status: :created, location: @workspace_orcid_user }
      else
        format.html { render :new }
        format.json { render json: @workspace_orcid_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workspace_orcid_users/1
  # PATCH/PUT /workspace_orcid_users/1.json
  def update
    respond_to do |format|
      if @workspace_orcid_user.update(workspace_orcid_user_params)
        format.html { redirect_to @workspace_orcid_user, notice: 'Workspace orcid user was successfully updated.' }
        format.json { render :show, status: :ok, location: @workspace_orcid_user }
      else
        format.html { render :edit }
        format.json { render json: @workspace_orcid_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workspace_orcid_users/1
  # DELETE /workspace_orcid_users/1.json
  def destroy
    @workspace_orcid_user.destroy
    respond_to do |format|
      format.html { redirect_to workspace_orcid_users_url, notice: 'Workspace orcid user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workspace_orcid_user
      @workspace_orcid_user = WorkspaceOrcidUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def workspace_orcid_user_params
      params.fetch(:workspace_orcid_user, {})
    end
end
