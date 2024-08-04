class WorkspacesController < ApplicationController
  before_action :set_workspace, only: [:show, :edit, :update, :destroy, :get_author_list, :get_stats, :get_file, :subscribe, :display_disclaimer, :accept_disclaimer, :latest_changes]

  def set_search_session
    [:search_type].each do |e|
      session[:ws_settings][e] = params[e] if params[e]
    end
  end

  def accept_disclaimer

    if current_user and current_user.orcid_user and readable? @workspace
      @share = Share.where(:user_id => current_user.id, :workspace_id => @workspace.id).first
      @share.update_attributes(:accepted_disclaimer_at => Time.now)
      redirect_to workspace_path(:key => @workspace.key)
    end
  end

  def display_disclaimer
    render :partial => "display_disclaimer"
  end

  def subscribe

    if current_user and current_user.orcid_user
      s = Share.new({:user_id => current_user.id, :email => current_user.email, :workspace_id => @workspace.id, :view_perm => true, :comment_perm => true})
      s.save
      #      @workspace.shares << s if !@workspace.shares.include? s
    end
    redirect_to workspace_path(:key => @workspace.key)
  end

  def latest_changes

    @all_articles = @workspace.articles
    @assertions = Assertion.where(:article_id => @all_articles.map{|e| e.id}).order("updated_at desc").limit(1000)
    @h_assertion_types = {} 
    AssertionType.all.map{|e| @h_assertion_types[e.id] = e}
    @h_articles = {}
    Article.where(:id => @assertions.map{|e| e.article_id}).all.map{|a| @h_articles[a.id] = a}
  end

  def get_file

    filepath = nil
    filename = nil
    if @workspace
      if params[:type] == 'attachment'
        filepath = @attachment_dir + params[:p]
      elsif params[:p]
        filepath = Pathname.new(APP_CONFIG[:data_dir]) + params[:p]
      end
      
      if readable?(@workspace)
        if File.exist? filepath
          fname = filepath.basename.to_s
          send_file filepath.to_s, type: params[:content_type] || 'text', #'application/octet-stream',
          x_sendfile: true, buffer_size: 512, disposition: (!params[:display]) ? ("attachment; filename=" + fname) : ''
          Basic.add_history("Download #{params[:p]}", @project, current_user, {:admin_only => true}) if params[:dl] == "1"
        else
          render :plain => "This file doesn't exist."
        end
      else
        render :plain => "This file is not readable."
      end
    else
      render :plain => 'Workspace not found'
    end


  end

  def get_stats
    
    if admin? or read_admin? #annotable?(@workspace)

      @h_groups = {
        "Verified" => ["Verified", "Verified by same authors"],
        "Verified by reproducibility project" => ["Verified by reproducibility project"],
        "Unchallenged" => ["Unchallenged, logically consistent", "Unchallenged, logically inconsistent", "Unchallenged"],
        "Challenged" => ["Challenged", "Challenged by same authors"],
        "Challenged by reproducibility project" => ["Challenged by reproducibility project"],
        "Partially verified" => ["Partially verified"],
        "Mixed" => ["Mixed"],
        "Others" => ["Reproduction in progress"]
      }

      @h_groups2 = {
        "Verified" => ["Verified", "Verified by same authors", "Verified by reproducibility project"],
        "Unchallenged" => ["Unchallenged, logically consistent", "Unchallenged, logically inconsistent", "Unchallenged"],
        "Challenged" => ["Challenged", "Challenged by same authors", "Challenged by reproducibility project"],
        "Partially verified" => ["Partially verified"],
        "Mixed" => ["Mixed"],
        "In progress" => ["Reproduction in progress"]
      }

      @h_color_groups2 = {
        "Verified" => "darkblue",
        "Unchallenged" => "lightgreen",
        "Challenged" => "red",
        "Partially verified" => "lightblue",
        "Mixed" => "grey",
        "In progress" => "darkgreen"
      }

      
      @h_rev_groups = {}
      @h_groups.keys.map{|k| @h_groups[k].map{|k2| @h_rev_groups[k2]=k}}
      @h_rev_groups2 = {}
      @h_groups2.keys.map{|k| @h_groups2[k].map{|k2| @h_rev_groups2[k2]=k}}

      @h_journal_types = {} #{:high => 0, :medium => 0, :low => 0}
      @journal_types = [:low, :medium, :high]
      
      @h_stats_by_group = {}
      
      @challenged_ids = [3, 10, 11]
      
      @articles = @workspace.articles

      @journals = Journal.where(:id => @articles.map{|a| a.journal_id}).all
      @h_journals = {}
      
      @journals.map{|j| @h_journals[j.id] = j; @h_journal_types[j.id] = (j.impact_factor and j.impact_factor > 50) ? :high : ((j.impact_factor and j.impact_factor > 10) ? :medium : :low) }
      
    
      
      @h_articles = {}
      @articles.map{|a| @h_articles[a.id] = a}
      @assertion_types =  AssertionType.all
      @h_assertion_types = {}
      @h_assertion_types2 = {}
      @assertion_types.map{|at| @h_assertion_types[at.id] = at; @h_assertion_types[at.name] = at}
      @h_assessment_types = {}
      @h_assessment_types2 = {}
      AssessmentType.all.map{|at|  @h_assessment_types[at.id] = at}
      @assertions = Assertion.where(:article_id => @articles.map{|a| a.id}, :obsolete => false).all
      @h_assertions_by_type = {}
      #    @h_assertions_by_type_and_assessment_type = {}
      @h_assertions = {}
      @h_rels_by_type = {}
      @assertions.each do |a|
        @h_assertions[a.id] = a
        @h_assertions_by_type[a.assertion_type_id] ||= []
        @h_assertions_by_type[a.assertion_type_id].push(a.id)
        #      @h_assertions_by_type_and_assessment_type[a.assertion_type_id] ||= {}
        #      @h_assertions_by_type_and_assessment_type[a.assertion_type_id][a.assessment_type_id] ||= []
        #      @h_assertions_by_type_and_assessment_type[a.assertion_type_id][a.assessment_type_id].push a.id
      end
      @assessement_type_by_claim_type = {}
      @h_rels ={}
      @h_rels_by_complement_and_type = {}
      @rels = Rel.where(:subject_id => @h_assertions.keys, :complement_id => @h_assertions.keys).all
      #  content = []
      #  if  params[:type] == 'assessment'
      content = [["claim type", "assessment type", "claim", "assessment", "journal", "publication year", "first author", "last author"]]
      # else
      #   content = [["claim type", "assessment type", "claim", "assessment", "journal", "publication year", "first author", "last author"]]
      # end
      @rels.each do |rel|
        @h_rels[rel.id] = rel
        subject = @h_assertions[rel.subject_id]
        complement =  @h_assertions[rel.complement_id]
        k1 = subject.assessment_type_id
        k2 = (complement) ? complement.assertion_type_id : nil
        k3 = subject.assertion_type_id
        @h_rels_by_type[rel.complement_id] ||= {}
        @h_rels_by_type[rel.complement_id][rel.rel_type_id] ||= []
        @h_rels_by_type[rel.complement_id][rel.rel_type_id].push rel.id
        if k1 and rel.rel_type_id == 2 
          #        k2 = @h_assertions[rel.complement_id].assertion_type_id
          #   if k1 < 5        
          @assessement_type_by_claim_type[k2] ||= {}
          @assessement_type_by_claim_type[k2][k1] ||= []
          @assessement_type_by_claim_type[k2][k1].push(rel.id)
        end
        article = @h_articles[complement.article_id]
        authors = article.authors_txt.split(";")
        last_author = authors.last
        first_author = authors.first
        journal = article.journal
        #      content.push(["bla", params[:type]])
        if params[:type] == 'assessment' and rel.rel_type_id == 2 and  @h_assertion_types[k2] and @h_assessment_types[k1] 
          l = [@h_assertion_types[k2].name, @h_assessment_types[k1].name, complement.content, subject.content, (journal) ? journal.name : 'NA', article.year, first_author, last_author]
          content.push(l)        
        elsif params[:type] == 'evidence' and k3 and  rel.rel_type_id == 1 #and @h_assertion_types[k3] and  @h_assertion_types[k2]
          l = [@h_assertion_types[k2].name, @h_assertion_types[k3].name, complement.content, subject.content, (journal) ? journal.name : 'NA', article.year, first_author, last_author]
          content.push(l)
        elsif params[:type] == 'comment' and k3 and rel.rel_type_id == 3 and  @h_assertion_types[k3] and  @h_assertion_types[k2]
          l = [@h_assertion_types[k2].name, @h_assertion_types[k3].name, complement.content, subject.content, (journal) ? journal.name : 'NA', article.year, first_author, last_author]
          content.push(l)
          
        end
      end

      @time_intervals = [[nil, 1991], [1992, 1996], [1997, 2001], [2002, 2006], [2007, nil]]
      @irreproducible_claims = []
      @all_claims = []
      @irreproducible_claims_by_journal = {}
      @irreproducible_claims_by_journal_type = {}
      
      @all_claims_by_journal = {}
      @all_claims_by_journal_type = {}
      
      all_challenged = Assertion.where(:assertion_type_id => @h_assertion_types['major_claim'].id, :assessment_type_id => @challenged_ids).all
      @all_challenged_journal_ids = all_challenged.map{|e| @h_articles[e.article_id].journal_id}.uniq #if all_challenged
   #   @all_challenged_journal_ids.each do |j_id|
      @journals.each do |j|
        @all_claims_by_journal[j.id]=[]
        @irreproducible_claims_by_journal[j.id]=[]
        #        @irreproducible_claims_by_journal_type[h_journal_types[j.id]]=
      end

      @journal_types.each do |jt|
        @irreproducible_claims_by_journal_type[jt]=[]
        @all_claims_by_journal_type[jt]=[]
      end
      
     # @irreproducible_claims.each_key do |k|
      #   cond = h_cond[k]
      @time_intervals.each do |interval|
        articles = []
        if interval[0] == nil
          articles = Article.where("year <= #{interval[1]}").all
        elsif interval[1] == nil
          articles = Article.where("year >= #{interval[0]}").all
        else
          articles = Article.where("year <= #{interval[1]} and year >= #{interval[0]}").all
        end
        all_assertions =  Assertion.where(:article_id => articles.map{|a| a.id}, :assertion_type_id => @h_assertion_types['major_claim'].id).all
        assertions = Assertion.where(:article_id => articles.map{|a| a.id}, :assertion_type_id => @h_assertion_types['major_claim'].id, :assessment_type_id => @challenged_ids).all
        #assertions = Rel.where(:complement_id => all_assertions.map{|e| e.id}, :rel_type_id => 2, :assessment_type_id => @challenged_ids).all #.select{|e| @h_assessment_types[e.assessment_type_id].name.match(/^Challenged/)}
        logger.debug("ASSERTION: " + assertions.size.to_s)
        @irreproducible_claims.push assertions
        @all_claims.push all_assertions
        @journals.each do |journal|
          journal_id = journal.id
          tmp_article_ids = articles.select{|a| a.journal_id == journal_id}.map{|a| a.id}
          @all_claims_by_journal[journal_id].push all_assertions.select{|e| tmp_article_ids.include?(e.article_id)}
          @irreproducible_claims_by_journal[journal_id].push assertions.select{|e| tmp_article_ids.include?(e.article_id)}
          
          @all_claims_by_journal_type[@h_journal_types[journal_id]].concat all_assertions.select{|e| tmp_article_ids.include?(e.article_id)}
          @irreproducible_claims_by_journal_type[@h_journal_types[journal_id]].concat assertions.select{|e| tmp_article_ids.include?(e.article_id)}
        end
        
      end

      ## by category
      @categories_data = []
      h_nber_by_category = {}
      @assessement_type_by_claim_type.each_key do |k1| 
        tmp_h = {} 
        @assessement_type_by_claim_type[k1].each_key do |k2|
          tmp_h[@h_rev_groups2[@h_assessment_types[k2].name]] ||= 0 
          tmp_h[@h_rev_groups2[@h_assessment_types[k2].name]] += @assessement_type_by_claim_type[k1][k2].size
        end
        h_nber_by_category[k1] = tmp_h
        #  total = tmp_h.values.sum
      end
      
# "Verified" => "darkblue",
#        "Unchallenged" => "lightgreen",
#        "Challenged" => "red",
#        "Partially verified" => "lightblue",
#        "Mixed" => "grey",
#        "In progress" => "darkgreen"

      list_categories = ["Verified", "Partially verified", "Mixed", "Challenged", "Unchallenged", "In progress"]
      total = h_nber_by_category[2].values.sum
      list_categories.each do |k|
        h = {
          :x => ['Major Claims'], 
          :y => [h_nber_by_category[2][k].to_f*100/total], 
          :name => k,
          :type => 'bar',
          :marker => { :color => @h_color_groups2[k] }
        }
        @categories_data.push h
      end


      
      respond_to do |format|
        format.html {
          if params[:nolayout] == '1'
            render :partial => 'get_stats'
          else
          end
        }
        format.text {
          render :plain => content.map{|t| t.join("\t")}.join("\n")
        }
      end
      
      
    else
      render :plain => "Not authorized."      
    end
    
  end

  def get_author_list

    content = []
    @workspace.articles.each do |a|
      authors = a.authors_txt.split(";")
      affs = Basic.safe_parse_json(a.affs_json, [])
      authors.each_index do |i|
        author = authors[i] 
        content.push([author, i+1, affs[i].join(", "), a.pmid, a.title, a.year])
      end
    end
    render :plain => content.map{|e| e.join("\t")}.join("\n")
  end
  
  def search
    session[:ws_settings][:free_text] = '' if !params[:free_text]
    session[:ws_settings][:page]=1 if !params[:page]
    session[:ws_settings][:search_view_type] ||= 'card'
    if params[:nolayout] == "1"
      render :layout => nil
    else
      render :layout => 'welcome'
    end
  end

   def do_search
     session[:ws_settings][:search_view_type] ||= 'card'
     session[:ws_settings][:search_view_type] = params[:search_view_type] if params[:search_view_type] and params[:search_view_type] != ''
     session[:ws_settings][:free_text] ||= ''
     session[:ws_settings][:free_text]=params[:free_text] if params[:free_text]
     session[:ws_settings][:search_type] ||= 'public'
     #  ['public'].each do |prefix|                                                                                                                                                                                                     
     session[:ws_settings]["per_page".to_sym]||=50 #if !session[:settings][(prefix + "_per_page").to_sym] or session[:settings][(prefix + "_per_page").to_sym]== 0                                                                         
     session[:ws_settings]["page".to_sym]||=1
     ['per_page', 'page'].each do |e|
       session[:ws_settings][e.to_sym]=params[e.to_sym].to_i if params[e.to_sym] and params[e.to_sym].to_i != 0
     end
     #  end                                                                                                                                                                                                                             

     free_text = session[:ws_settings][:free_text]

     free_text.strip!

     words = free_text.split(/\s*[; ]\s*/)

     @workspaces = []

     @h_journals = {}
     Journal.all.map{|j| @h_journals[j.id] = j}

     @h_counts = {
       :all => Workspace.count
     }

     @query = Workspace.search do
       fulltext words.join(" ").gsub(/\$\{jndi\:/, '').gsub(/[\{\}\$\:\\]/, '')
       #   with :public, true       
       order_by(:nber_annot_articles, :desc)
       order_by(:updated_at, :desc)
       paginate :page => session[:ws_settings][:page], :per_page => session[:ws_settings][:per_page]
     end

     @workspaces= @query.results
     
     @h_nber={:articles => {}, :annot_articles => {}}

     @workspaces.map{|ws| @h_nber.keys.map{|k| @h_nber[k][ws.id]=0}}
     annot_articles = Article.select("distinct(article_id)").joins(:assertions).where(:workspace_id => @workspaces.map{|ws| ws.id}).all
     h_annot_articles={}
     annot_articles.each do |a|
       h_annot_articles[a.article_id] = 1
     end
     articles = Article.select("workspace_id, id").where(:workspace_id => @workspaces.map{|ws| ws.id}).all
     articles.each do |a|
       @h_nber[:articles][a.workspace_id]+=1
       @h_nber[:annot_articles][a.workspace_id]+=1 if h_annot_articles[a.id]
     end
     
#     Assertion.select("distinct article_id").where(:article_id => articles.map{|a| a.id}).each do 
     
     render :partial => 'do_search' #'search_' + session[:settings][:search_view_type] + "_view"         
     
   end

  # GET /workspaces
  # GET /workspaces.json
  def index
    @workspaces = [] #Workspace.all
    session[:ws_settings][:free_text] = ''
    session[:ws_settings][:page]=1    
  end

  def update_shares
 
     ## update shares                                                                                                                                   
    if current_user
      orphan_emails = @workspace.shares.select{|s| !s.user_id}.map{|e| e.email}.uniq
      users = User.where(:email => orphan_emails).all
      h_users = {}
      users.map{|u| h_users[u.email] = u}
#      orphan_emails.map{|e| h_users[u.em]}                                                                                                            
      @workspace.shares.select{|s| !s.user_id}.each do |s|
        if h_users[s.email]
          s.update_attributes({:user_id => h_users[s.email].id})
        end
      end
    end

  end

  # GET /workspaces/1
  # GET /workspaces/1.json
  def show

    params[:tab]||='articles'

    ### contribute if not yet contributer                                                                                                                                       
    if current_user and current_user.orcid_user
      h = {:user_id => current_user.id, :email => current_user.email, :workspace_id => @workspace.id, :view_perm => true, :comment_perm => true}
      s = Share.where(h).first
      if !s
        s = Share.new(h)
        s.save
      end
    end
    
    update_shares()
    if readable? @workspace
      @share = Share.where(:workspace_id => @workspace.id, :user_id => current_user.id).first
      render
    else
      render 'shared/unauthorized'
    end
    
  end

  # GET /workspaces/new
  def new
    @workspace = Workspace.new   
  end

  # GET /workspaces/1/edit
  def edit

    if editable? @workspace
      @shares = @workspace.shares.to_a
      
      render :layout => (params[:no_layout]) ? false : true
    else
      render 'shared/unauthorized'
    end

  end

  # POST /workspaces
  # POST /workspaces.json
  def create
    @workspace = Workspace.new(workspace_params)
    @workspace.key = Basic.create_key(Workspace, 6)

    respond_to do |format|
      if @workspace.save
        format.html { redirect_to @workspace, notice: 'Workspace was successfully created.' }
        format.json { render :show, status: :created, location: @workspace }
      else
        format.html { render :new }
        format.json { render json: @workspace.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workspaces/1
  # PATCH/PUT /workspaces/1.json
  def update
    respond_to do |format|
      if editable? @workspace and @workspace.update(workspace_params)
        format.html { redirect_to workspace_path(:key => @workspace.key), notice: 'Workspace was successfully updated.' }
        format.json { render :show, status: :ok, location: @workspace }
      else
        format.html { render :edit }
        format.json { render json: @workspace.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workspaces/1
  # DELETE /workspaces/1.json
  def destroy
    @workspace.destroy
    respond_to do |format|
      format.html { redirect_to workspaces_url, notice: 'Workspace was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workspace      
      @workspace = Workspace.find_by_key(params[:key])
      @attachment_dir = Pathname.new(APP_CONFIG[:data_dir]) + "attachments" + @workspace.key
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def workspace_params
      params.fetch(:workspace).permit(:name, :short_description, :description, :disclaimer, :contributors, :key, :how_to_contribute)
    end
end
