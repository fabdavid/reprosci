class AssertionsController < ApplicationController
  before_action :set_assertion, only: [:show, :edit, :update, :destroy, :get_details, :get_history]

  
  def set_search_session
    [:search_type].each do |e|
      session[:as_settings][e] = params[e] if params[e]
    end
  end

  def search
    session[:as_settings][:free_text] ||= '' if !params[:free_text]
    session[:as_settings][:page] ||= 1 if !params[:page]
    session[:as_settings][:at_ids] ||= [1, 2, 3, 7] #(1 .. AssertionType.count()).to_a 
    session[:as_settings][:search_view_type] ||= 'card'

    @workspace = nil
    if params[:workspace_key]
      @workspace = Workspace.where(:key => params[:workspace_key]).first
    end
    #   session[:as_settings][:at_ids] ||= (1 .. 7).to_a
    if params[:nolayout] == "1"
      render :layout => nil
    else
      render 
    end
  end

   def do_search
     session[:as_settings][:search_view_type] ||= 'card'
     session[:as_settings][:search_view_type] = params[:search_view_type] if params[:search_view_type] and params[:search_view_type] != ''
     session[:as_settings][:at_ids] = params[:at_ids].split(",").map{|e| e.to_i} #if params[:at_ids]
     session[:as_settings][:free_text] ||= ''
     session[:as_settings][:free_text]=params[:free_text] if params[:free_text]
     session[:as_settings][:search_type] ||= 'public'

     session[:as_settings]["per_page".to_sym]||=50 #if !session[:settings][(prefix + "_per_page").to_sym] or session[:settings][(prefix + "_per_page").to_sym]== 0                                                     
     session[:as_settings]["page".to_sym]||=1
     ['per_page', 'page'].each do |e|
       session[:as_settings][e.to_sym]=params[e.to_sym].to_i if params[e.to_sym] and params[e.to_sym].to_i != 0
     end
     free_text = session[:as_settings][:free_text]
     
     free_text.strip!

     words = free_text.split(/\s*[; ]\s*/)

     @h_assertion_types = {}
     AssertionType.all.map{|at| @h_assertion_types[at.id] = at}

     @h_assessment_types = {}
     AssessmentType.all.map{|at| @h_assessment_types[at.id] = at}
     
     @assertions = []

     @h_journals = {}
     Journal.all.map{|j| @h_journals[j.id] = j}

     conds = ["content != '' and assertion_type_id in (?) and assertions.obsolete=false and articles.obsolete=false", session[:as_settings][:at_ids]]
   
     workspace_val = nil
     @workspace = nil
     if params[:workspace_key]
       @workspace = Workspace.where(:key => params[:workspace_key]).first 
       workspace_cond = " and workspace_id = ?"
       workspace_val = @workspace.id
       conds[0] += workspace_cond
       conds.push workspace_val
     end
     @h_counts = {
       :all => Assertion.joins(:article).where(conds).count
     }
     
     #     constraint_at_ids = (params[:assessment_type_id] == '') ? (1 .. AssertionType.count).to_a : AssertionType.where(:name => ['major_claim', 'minor_claim', 'method', 'evidence']).all.map{|e| e.id}

     @query = Assertion.search do
       fulltext words.join(" ").gsub(/\$\{jndi\:/, '').gsub(/[\{\}\$\:\\]/, '')
       #order_by(:updated_at, :desc)
       without(:content, nil)
       with(:workspace_id, workspace_val) if workspace_val
       with(:assertion_type_id, (session[:as_settings][:at_ids].size > 0) ? session[:as_settings][:at_ids] : [-1]) # & constraint_at_ids)
       with(:assessment_type_id, (params[:assessment_type_id] == '5') ? [params[:assessment_type_id], ''] : params[:assessment_type_id])  if params[:assessment_type_id] != ''
       with(:obsolete, false)
       with(:obsolete_article, false)
       paginate :page => session[:as_settings][:page], :per_page => session[:as_settings][:per_page]
     end
     
     @assertions= @query.results
     @num = @assertions.size
     @h_articles = {}
     Article.where(:id => @assertions.map{|as| as.article_id}.uniq).all.each do |a|
       @h_articles[a.id] = a
     end

     @h_assessment_by_assertion = {}
     @assessments = Rel.select("rels.*, assertions.assessment_type_id").joins("join assertions on (assertions.id = subject_id)").joins(:rel_type).where("assertions.obsolete is false and rel_types.name = 'assessment' and complement_id in (?)", @assertions.map{|e| e.id}).all
     @assessments.each do |a|
       @h_assessment_by_assertion[a.complement_id] = a
     end

     @h_nber_comments = {}
     @assertions.map{|e|  @h_nber_comments[e.id] = 0}
     Rel.where(:rel_type_id => 3, :complement_id => @assertions.map{|e| e.id}).all.each do |rel|
       @h_nber_comments[rel.complement_id]+=1
     end
     
     render :partial => 'do_search' #'search_' + session[:settings][:search_view_type] + "_view"                                                              
     
   end

  def get_history


    @h_assertion_types = {}
    AssertionType.all.map{|at| @h_assertion_types[at.id] = at}

    @rels = Rel.where(:complement_id => @assertion.id).all
    subject_ids = @rels.map{|e| e.subject_id} 
    @h_assertions = {@assertion.id => @assertion}

    @subjects = Assertion.where(:id => subject_ids, :obsolete => false).all.map{|e| @h_assertions[e.id] = e}.select{|e| e.content != ''}

    assertion_ids =  [@assertion.id] + subject_ids

    @h_last_version_assertion= {}
    @assertion_versions = AssertionVersion.where(:assertion_id => assertion_ids).all.select{|e| e.content != ''}.sort{|a, b| a.created_at <=> b.created_at}.map{|a| @h_last_version_assertion[a.assertion_id] = a; a}.select{|a| a.minor == false} # check = (a.minor == false or !h_found_assertion[a.assertion_id]);  h_found_assertion[a.assertion_id] = (a.minor) ? 2 : 1; check}.reverse

    ### we assume we will only have one rel for a subject in the same article
    @h_rels = {}
    @rels.each do |rel|
      @h_rels[rel.subject_id]= rel.complement_id
    end


    @h_users = {}
    User.where(:id => @assertion_versions.map{|o| o.user_id}).all.map{|u| @h_users[u.id] = u}

    render :partial => 'get_history'

  end

  def get_details

    @h_assessment_types ={}
    AssessmentType.all.map{|at| @h_assessment_types[at.id] = at}
    
    @h_assertion_types = {}
    AssertionType.all.map{|at| @h_assertion_types[at.id] = at}

    @h_rel_types_by_name = {}
    @h_rel_types = {}
    RelType.all.map{|rt| 
      @h_rel_types_by_name[rt.name] = rt
      @h_rel_types[rt.id] = rt
    }

    @active_tab = @h_rel_types[params[:rel_type_id].to_i].name

    #    @h_counts = {}
    @h_rels = {:by_compl => {}, :by_subj => {}}
    h_assertion_ids = {@assertion.id => 1}

    #    option = ''
    #    if !admin?
    option = "assertions.obsolete is false and "
    #    end
    Rel.joins("join assertions on (subject_id = assertions.id)").where(option + "complement_id in (?)", @assertion.id).order("assertions.rank asc").all.each do |rel|
     h_assertion_ids[rel.subject_id] = 1
      @h_rels[:by_compl][@h_rel_types[rel.rel_type_id].name]||={}
      @h_rels[:by_compl][@h_rel_types[rel.rel_type_id].name][rel.complement_id] ||=[]
      @h_rels[:by_compl][@h_rel_types[rel.rel_type_id].name][rel.complement_id].push rel.subject_id
    end

    @h_assertions = {}
    Assertion.where(:id => h_assertion_ids.keys).all.each do |a|
      @h_assertions[a.id] = a
    end
    
    @h_last_assertion_version = {}    
    assertion_versions = AssertionVersion.where(:assertion_id => @h_assertions.keys).order('created_at desc').all
    assertion_versions.each do |av|
      @h_last_assertion_version[av.assertion_id] = av if !@h_last_assertion_version[av.assertion_id]
    end


    render :partial => 'get_details'
  end

  # GET /assertions
  # GET /assertions.json
  def index
    @assertions = [] #Assertion.all
  end

  # GET /assertions/1
  # GET /assertions/1.json
  def show
  end

  # GET /assertions/new
  def new
    if params[:article_key]
      @article = Article.where(:key => params[:article_key]).first
      @workspace = @article.workspace
      if annotable? @workspace
        @h_rel_types = {}
        RelType.all.map{|e| @h_rel_types[e.subject_type_id] = e}
        @assertion = Assertion.new(:article_id => @article.id, :assertion_type_id => params[:assertion_type_id])
        @assertion_type = AssertionType.where(:id => params[:assertion_type_id]).first
        render :partial => "new"
      else
        render :partial => "shared/unauthorized"
      end
    else
      render :partial => 'shared/invalid'
    end
  end

  # GET /assertions/1/edit
  def edit
    if params[:article_key] and @assertion and @article.key == params[:article_key]
      if (commentable? @workspace and @assertion.assertion_type_id == 7) or annotable? @workspace
        @h_rel_types = {}
        RelType.all.map{|e| @h_rel_types[e.subject_type_id] = e}
        render :partial => "edit"
      else
        render :partial => "shared/unauthorized"
      end
    else
      render :partial => 'shared/invalid'
    end

  end


  # POST /assertions
  # POST /assertions.json
  def create
    @assertion = Assertion.new(assertion_params)
  
    if params[:article_key] and @assertion.assertion_type_id and @assertion.content and !@assertion.content.empty?
      @article = Article.where(:key => params[:article_key]).first
      @workspace = @article.workspace            

      if annotable? @workspace 
        @assertion.article_id = @article.id
        @assertion.user_id = current_user.id
        @assertion.orcid_user_id = current_user.orcid_user_id
        @assertion.rank = Assertion.where(:article_id => @article.id, :assertion_type_id => @assertion.assertion_type_id).count + 1
        
        #   @assertion.content_modified_at = Time.now
       
        if params[:file]  and  params[:file].original_filename
          @assertion.ext = params[:file].original_filename.split(".").last
        end
        
        respond_to do |format|
          if @assertion.save            
            
            Basic.upd_workspace_stats @workspace

            #save file if there is one
            if params[:file]  and  params[:file].original_filename
              attachment_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'attachments' + @workspace.key
              Dir.mkdir(attachment_dir) if !File.exist?(attachment_dir)
         #     ext = params[:file].original_filename.split(".").last
              filepath = attachment_dir + (@assertion.id.to_s + "." + @assertion.ext.gsub(/[^\w\d]+/, '_'))
              File.open(filepath, 'wb') do |f|
                f.write(params[:file].read())
              end
            end

            h_assertion_version = {
              :content => @assertion.content,
              :assertion_id => @assertion.id,
              :all_tags_json => @assertion.all_tags_json,
              :user_id => current_user.id,
              :orcid_user_id => current_user.orcid_user_id
            }
            assertion_version = AssertionVersion.new(h_assertion_version)
            assertion_version.save

            Basic.upd_tags(@assertion)

            # add mandatory assessment if assertion type is OK
            if @assertion.assertion_type.is_assessed == true
              as = Assertion.new(:assertion_type_id => 6, :content => '', :rank => 1, :article_id => @article.id, :assessment_type_id => 5, :user_id => current_user.id, :orcid_user_id => current_user.orcid_user_id) 
              as.save
              as_v = AssertionVersion.new({:assertion_id => as.id, :content => '', :version => 1, :user_id => current_user.id, :orcid_user_id => current_user.orcid_user_id})
              as_v.save
              rel = Rel.new(:subject_id => as.id, :user_id => current_user.id, :orcid_user_id => current_user.orcid_user_id, :complement_id => @assertion.id, :rel_type_id => 2)
              rel.save
            end
            #            @assertion_type = @assertion.assertion_type
            @to_refresh_assertion_type = @assertion.assertion_type
            format.html { render :partial => 'create' }
            format.json { render :show, status: :created, location: @assertion }
          else
            format.html { render :partial => 'shared/error', :locals => {:error => @assertion.errors } }
            format.json { render json: @assertion.errors, status: :unprocessable_entity }
          end
        end
      else
        render :partial => 'shared/unauthorized'
      end
    else
      render :partial => 'shared/invalid'
    end
  end
  
  # PATCH/PUT /assertions/1
  # PATCH/PUT /assertions/1.json
  def update
    if (commentable? @workspace and @assertion.assertion_type_id == 7) or annotable? @workspace
      assertion_type = @assertion.assertion_type
      params[:minor] = true if assertion_type.name == 'comment'
      
      if params[:file]
        logger.debug(params[:file].original_filename)
      end
      if params[:file]
        params[:assertion][:ext] = (params[:file]) ? params[:file].original_filename.split(".").last : nil
      end
      params[:assertion][:user_id] = (params[:minor] = true) ? @assertion.user_id : current_user.id
      last_assertion_version = AssertionVersion.where(:assertion_id => @assertion).order("version desc").first
      if params[:assertion][:content] != @assertion.content and params[:assertion][:obsolete] != 'true' and last_assertion_version
        h_assertion_version = {
          :content => params[:assertion][:content],
          :all_tags_json => params[:assertion][:all_tags_json],
          :assertion_id => @assertion.id,
          :user_id => current_user.id,
          :orcid_user_id => current_user.orcid_user_id,
          :minor => params[:minor],
          :version => (params[:minor] == true) ? last_assertion_version.version : last_assertion_version.version + 1
        }
        assertion_version = AssertionVersion.new(h_assertion_version)
        assertion_version.save
      end
      respond_to do |format|
        if @assertion.update(assertion_params)

          #save file if there is one                                                                                                                                          
          if params[:file]
            attachment_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'attachments' + @workspace.key
            Dir.mkdir(attachment_dir) if !File.exist?(attachment_dir)            
            filepath = attachment_dir + (@assertion.id.to_s + "." + @assertion.ext.gsub(/[^\w\d]+/, '_'))
            File.open(filepath, 'wb') do |f|
              f.write(params[:file].read())
            end
          end
                    
          Basic.upd_tags(@assertion)

          if assertion_type.name == 'assessment'
            rel = Rel.joins(:rel_type).where(:subject_id => @assertion.id, :rel_types => {:name => 'assessment'}).first 
            complement = Assertion.where(:id => rel.complement_id).first
            complement.update_attributes(:assessment_type_id => @assertion.assessment_type_id)
          end
        #  if params[:assertion][:obsolete] == true
        #  rels = Rel.joins(:rel_type).where(:subject_id => @assertion.id}).all
        #  rels.update_all({:obsolete => true})
        # end  
          if @assertion.obsolete == true and params[:complement_id]
            rel = Rel.where(:subject_id => @assertion.id, :complement_id => params[:complement_id], :rel_type_id => params[:rel_type_id]).first
            rel.update_attributes({:obsolete => true})
          end

          Sunspot.index @assertion

          @to_refresh_assertion_type = AssertionType.where(:id => (params[:to_refresh_assertion_type_id]) ? params[:to_refresh_assertion_type_id].to_i : @assertion.assertion_type_id).first
          format.html { render :partial => 'create' }
          format.json { render :show, status: :ok, location: @assertion }
        else
          format.html { render :partial => 'shared/error', :locals => {:error => @assertion.errors } }
          format.json { render json: @assertion.errors, status: :unprocessable_entity }
        end
      end
    else
      render :partial => 'shared/unauthorized'
    end
  end

  # DELETE /assertions/1
  # DELETE /assertions/1.json
  def destroy
    if  annotable? @workspace
      Rel.where(:subject_id => @assertion.id).all.destroy_all
      @assertion.assertion_versions.destroy_all
      # Rel.where(:complement_id => @assertion.id).all.destroy_all
      @assertion.destroy
      Basic.upd_workspace_stats @workspace
    end
    respond_to do |format|
      format.html { redirect_to assertions_url, notice: 'Assertion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assertion
      @assertion = Assertion.find(params[:id])
      @article = @assertion.article
      @workspace = @article.workspace
      @assertion_type = @assertion.assertion_type
      @attachment_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'attachments' + @workspace.key
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assertion_params
      params.fetch(:assertion).permit(:content, :assertion_type_id, :article_id, :user_id, :obsolete, :assessment_type_id, :all_tags_json, :ext, :pmid)
    end
end
