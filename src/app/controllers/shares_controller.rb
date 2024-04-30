class SharesController < ApplicationController
  before_action :set_share, only: [:show, :edit, :update, :destroy, :ban, :unban]


  def ban    
    if editable? @workspace #and params[:workspace_id] == @workspace.id.to_s
      user = @share.user
      @share.update_attribute(:banned, true)
      if ou = user.orcid_user
        h_wou = {
          :workspace_id => @workspace.id,
          :orcid_user_id => ou.id,
          :banned => true
        }
        wou =  WorkspaceOrcidUser.where(h_wou).first
        if wou
          wou.update_attributes(:banned => true)
        end
      end
    end
    @shares = @workspace.shares.to_a
    render :partial => "workspaces/shares"
  end
  
  def unban
   if editable? @workspace# and params[:workspace_id] == @workspace.id.to_s
     user = @share.user
     @share.update_attribute(:banned, false)
     if ou = user.orcid_user
       h_wou = {
          :workspace_id => @workspace.id, 
          :orcid_user_id => ou.id,
          :banned => true
        }
       wou =  WorkspaceOrcidUser.where(h_wou).first
       if wou
         wou.update_attributes(:banned => false)
       end
     end
   end
    @shares = @workspace.shares.to_a
    render :partial => "workspaces/shares"
    
  end

  # GET /shares
  # GET /shares.json
  def index
    @shares = Share.all
  end

  # GET /shares/1
  # GET /shares/1.json
  def show
  end

  # GET /shares/new
  def new
    @share = Share.new
  end

  # GET /shares/1/edit
  def edit
  end

  # POST /shares
  # POST /shares.json
  def create
    @share = Share.new(share_params)
    @workspace = Workspace.where(:key => params[:workspace_key]).first
    logger.debug("asblasda")
    if shareable? @workspace
      user = User.where(:email => @share.email).first
      @password = nil
#      if !user
#        @password = Basic.create_key(nil, 20)
#        user = User.new({:email => @share.email, :password => @password, :password_confirmation => @password})
#        user.save() #{:validate => false})
#      end
#      existing_share = Share.where(:user_id => (user) ? user.id : nil, :workspace_id => @workspace.id).first
      @share.workspace_id = @workspace.id
#      logger.debug("gggg")
      if @workspace #user and @workspace #@share.email and params[:workspace_key] #and !existing_share
#        logger.debug("titi")
        @share.workspace_id = @workspace.id
        @share.user_id = (user) ? user.id : nil #if user
        if user and ou = user.orcid_user
           wou = WorkspaceOrcidUser.where(:workspace_id => @workspace.id, :orcid_user_id => orcid_user.id).first
          if !wou
            wou = WorkspaceOrcidUser.new(:workspace_id => @workspace.id, :orcid_user_id => orcid_user.id)
            wou.save
          end
        end
#        logger.debug("toto")
        if @share.save
#          logger.debug("toi")
          @shares = @workspace.shares.to_a
          UserMailer.invitation_mail(current_user, @share, @password).deliver
        end
      end
      @shares = @workspace.shares.to_a if !@shares
      
      respond_to do |format|
        if @share.save
          format.html { render :partial => 'workspaces/shares' }
          format.json { render :show, status: :created, location: @share }
        else
          format.html { render :new }
          format.json { render json: @share.errors, status: :unprocessable_entity }
        end
      end
    else
      render 'shared/unauthorized'
    end
  end

  # PATCH/PUT /shares/1
  # PATCH/PUT /shares/1.json
  def update
    respond_to do |format|
      if @share.update(share_params)
        format.html { redirect_to @share, notice: 'Share was successfully updated.' }
        format.json { render :show, status: :ok, location: @share }
      else
        format.html { render :edit }
        format.json { render json: @share.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shares/1
  # DELETE /shares/1.json
  def destroy
    @share.destroy
    respond_to do |format|
      format.html { redirect_to shares_url, notice: 'Share was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_share
      @share = Share.find(params[:id])
      @workspace = @share.workspace
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def share_params
      params.fetch(:share).permit(:email, :view_perm, :comment_perm, :annot_perm, :share_perm, :edit_perm)
    end
end
