class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :admin?, :read_admin?, :superadmin?, :autorized?, :editable?, :readable?, :commentable?, :annotable?, :shareable?, :editable?, :banned_user?
  before_action :init_session
  before_action :configure_permitted_parameters, if: :devise_controller?

  def superadmin?
     current_user and ENV['SUPERADMIN'].split(",").include?(current_user.email)
  end
  
  def admin?
    current_user and ENV['ADMIN'].split(",").include?(current_user.email)
  end

  def read_admin?
    current_user and ENV['READ_ADMIN'].split(",").include?(current_user.email)
  end

  def banned_user? s, u, w
    s and (s.banned == true or (u and ou = u.orcid_user and wou = WorkspaceOrcidUser.where(:workspace_id => w.id, :orcid_user_id => ou.id).first and wou.banned == true)) 
  end

  def readable? p
    admin? or read_admin? or (p and (p.is_public == true or 
                      (current_user and p.user_id ==current_user.id) or 
                      (current_user and share = p.shares.select{|s| s.user_id == current_user.id #and (s.created_at < Time.utc(2023, 06, 8) or Time.now > Time.utc(2023, 07, 04))
                       }.first and share.view_perm == true))) #or ip_restricted_access(p, request)
  end

  def commentable? p
    admin? or 
      (p and (p.is_public == true or
              (current_user and p.user_id ==current_user.id) or
              (current_user and share = p.shares.select{|s| s.user_id == current_user.id #and (s.created_at < Time.utc(2023, 06, 8) or Time.now > Time.utc(2023, 07, 04))
               }.first and share.comment_perm == true))) #or ip_restricted_access(p, request) 
  end
  
  
  def annotable? p
    admin? or
      (p and (p.is_public == true or
              (current_user and p.user_id ==current_user.id) or
              (current_user and share = p.shares.select{|s| s.user_id == current_user.id}.first and share.annot_perm == true))) #or ip_restricted_access(p, request)  
  end
  
  def shareable? p
    admin? or
      (p and (p.is_public == true or
              (current_user and p.user_id ==current_user.id) or
              (current_user and share = p.shares.select{|s| s.user_id == current_user.id}.first and share.share_perm == true))) #or ip_restricted_access(p, request)                             
  end
  
    def editable? p
    admin? or
      (p and (p.is_public == true or
              (current_user and p.user_id ==current_user.id) or
              (current_user and share = p.shares.select{|s| s.user_id == current_user.id}.first and share.edit_perm == true))) #or ip_restricted_access(p, request)                                                                                                                                               
  end


  def authorized? 
    h_settings = Basic.safe_parse_json(@workspace.settings_json, {})
    (current_user and @workspace and current_user.id == @workspace.user_id) or (current_user and h_settings['authorized_users'].include? current_user.email) or (@workspace and @workspace.is_public == true) or admin?
  end

#  def editable? p
#     h_settings = Basic.safe_parse_json(p.settings_json, {})
#    (current_user and p and current_user.id == p.user_id) or (current_user and h_settings['authorized_users'].include? current_user.email) or (p and p.is_public == true) or admin?
#  end
  
  def init_session
    session[:article_settings]||={:limit => 10, :free_text => ''}
    session[:ws_settings]||={:limit => 10, :free_text => ''}
    session[:as_settings]||={:limit => 10, :free_text => '', :at_ids => [1, 2, 3, 7] #(1 ..7).to_a
    }
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end
  
  
end
