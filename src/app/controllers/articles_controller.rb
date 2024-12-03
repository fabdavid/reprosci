class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy, :get_assertion_type, :get_author_form, :set_assertion_order, :upd_create_author, :validate]

  def validate
    if params[:validate] == '1'
      @article.update_attributes({:validated_by => current_user.id, :validated_at => Time.now})
      render :partial => "validate"
    elsif params[:validate] == '0'
      @article.update_attributes({:validated_by => nil, :validated_at => nil})
      render :partial => "unvalidate"
    else
      render :nothing => true
    end
  end

  def get_author_form

    @author = Author.where(:article_id => @article.id, :name => params[:author]).first
    if !@author
      @author = Author.new(:article_id => @article.id, :name => params[:author])
    end
    render :partial => 'authors/form', :locals => {:author => @author}
    
  end

  def set_assertion_order
    if annotable? @workspace
      #      assertions = Assertion.where(:article_id => @article.id, :assertion_type_id => params[:assertion_type_id]).all
      #      h_assertions = {}
      #      h_assertions.
      #   assertion_ids = @h_assertion_ids_by_type[@h_assertion_types[params[:assertion_type_id].to_i].name.to_sym] & params[:assertion_types].split(",").map{|e| e.to_i}
      rank = 1
      @log=''
      params[:assertion_ids].split(",").map{|e| e.to_i}.each do |assertion_id|
        if @h_assertions[assertion_id].assertion_type_id == params[:assertion_type_id].to_i
          @h_assertions[assertion_id].update_attributes({:rank => rank})

          @log+= "change"
          rank += 1 
        else
          @log += 'bad'
        end
      end
    end
    render :partial => 'set_assertion_order_js'
  end
  
  def set_search_session
    [:article_search_type].each do |e|
      session[:article_settings][e] ||= params[e] if params[e]
    end
  end

  def search
    session[:article_settings][:search_view_type] ||= 'card'
    session[:article_settings][:free_text] = params[:free_text] if params[:free_text]
    @workspace = Workspace.where(:key => params[:workspace_key]).first
    journal_ids = @workspace.articles.map{|a| a.journal_id}.uniq
    @journals = Journal.where(:id => journal_ids).all
    if params[:nolayout] == "1"
      render :layout => nil
    else
      render :layout => 'welcome'
    end
  end
  
  def do_search
    session[:article_settings][:search_view_type] ||= 'card'
    session[:article_settings][:search_view_type] = params[:search_view_type] if params[:search_view_type] and params[:search_view_type] != ''
    session[:article_settings][:free_text] ||= ''
    session[:article_settings][:free_text] = params[:free_text] if params[:free_text]
    session[:article_settings][:search_type] ||= 'public'
    #  ['public'].each do |prefix|
    session[:article_settings]["per_page".to_sym]||=50 #if !session[:settings][(prefix + "_per_page").to_sym] or session[:settings][(prefix + "_per_page").to_sym]== 0               
    session[:article_settings]["page".to_sym]||=1
    ['per_page', 'page'].each do |e|
      session[:article_settings][e.to_sym] = params[e.to_sym].to_i if params[e.to_sym] and params[e.to_sym].to_i != 0
    end
    #  end
    
    free_text = session[:article_settings][:free_text]
    
    free_text.strip!
    
    words = free_text.split(/\s*[; ]\s*/)
    
    @workspace = Workspace.where(:key => params[:workspace_key]).first if params[:workspace_key]
    
    @articles = []
    
    @h_counts = {
      :all => Article.count
    }
    
    @query = Article.search do
      fulltext words.join(" ").gsub(/\$\{jndi\:/, '').gsub(/[\{\}\$\:\\]/, '')
      #   with :public, true
      with :workspace_id, @workspace.id if @workspace
      with :validated_at, nil if params[:only_not_validated]
      with :journal_id, params[:journal_id] if params[:journal_id]
      order_by(:nber_claims, :desc)
      order_by(:updated_at, :desc)
      paginate :page => session[:article_settings][:page], :per_page => session[:article_settings][:per_page]
    end
    
    @articles= @query.results

    @h_journals = {}
    @journals = Journal.all
    @journals.map{|j| @h_journals[j.id] = j}

    
    @h_nber = {:claim => {}, :method => {}, :evidence => {}, :assessment => {}, :comment => {}}
    @h_nber.each_key do |k|
      Assertion.select("article_id").joins(:assertion_type).where(["obsolete is false and content != '' and assertion_types.name ~ ?", k.to_s]).all.each do |a|
        @h_nber[k][a.article_id]||=0
        @h_nber[k][a.article_id]+=1
      end
    end
    
    #    elsif session[:settings][:search_type] == 'public'                                                                                                                                                                
    #     if current_user and !admin?
    #       @query = Project.search do
    #         fulltext words.join(" ")
    #         with :user_id, current_user.id
    #         order_by(:modified_at, :desc)
    #         paginate :page => session[:settings][:my_page], :per_page =>  session[:settings][:my_per_page]
    #      end
    #    elsif admin?
    #      @query = Project.search do
    #        fulltext words.join(" ")
    #        order_by(:modified_at, :desc)
    #        paginate :page => session[:settings][:my_page], :per_page =>  session[:settings][:my_per_page]
    #      end
    #    end
    
    #     @projects = @query.results
    now = Time.now
    #     if params[:auto] and (params[:public_project_ids] == @public_projects.map{|p| p.id}.join(",") and params[:my_project_ids] == @projects.map{|p| p.id}.join(",") and
    #                           @public_projects.select{|p| now -p.modified_at <10}.size == 0 and @projects.select{|p| now -p.modified_at <10}.size == 0)
    #      render :nothing => true, :body => nil
    #    else
    render :partial => 'do_search' #'search_' + session[:settings][:search_view_type] + "_view"                                                                                                                          
    #    end
    
  end
  
  def get_assertion_type
    
    if params[:assertion_type_id]
      if readable? @workspace
        render :partial => 'display_assertion_type', :locals => {:assertion_type => @h_assertion_types[params[:assertion_type_id].to_i]}
      else
        render :partial => 'shared/unauthorized'
      end
    else
      render :partial => 'shared/invalid'
    end
  end
  
  
  # GET /articles
  # GET /articles.json
  def index
    #    @articles = Article.all
    #    @h_nber_assertions||={}
    #    Assertion.select("article_id").where(:assertion_type_id => [1, 2, 3]).all.each do |a|
    #      @h_nber_assertions[a.article_id]||=0
    #      @h_nber_assertions[a.article_id]+=1
    #    end
    session[:article_settings][:free_text] = ''
    session[:article_settings][:page]=1

     respond_to do |format|
       format.html {}
       format.text {
         if read_admin?
           @workspace = Workspace.where(:key => params[:workspace_key]).first if params[:workspace_key]
           @articles = (@workspace) ? @workspace.articles : Article.all
           assertions = Assertion.where(:article_id => @articles.map{|a| a.id}).all
           h_article_ids = {}
           assertions.map{|a| h_article_ids[a.article_id] = 1}
           #         @articles.select!{|a| h_article_ids[a.id]}
           render :plain => ["Article ID", "Authors", "Title", "Year", "PMID"].join("\t") + "\n" + @articles.select{|a| !params[:only_annotated] or h_article_ids[a.id]}.map{|a| [a.id, a.authors_txt, a.title, a.year, a.pmid].join("\t")}.join("\n") + "\n"
         end
       }
     end
     
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
 #   session[:as_settings][:free_text] = '' if !params[:free_text]
 #   session[:as_settings][:page]=1 if !params[:page]
 #   session[:as_settings][:at_ids] = (1 .. AssertionType.count()).to_a
 #   session[:as_settings][:search_view_type] ||= 'card'

    @h_rel_types = {}
    RelType.all.map{|e| @h_rel_types[e.name] = e.id}

  end

  # GET /articles/new
  def new
    @workspace = Workspace.where(:key => params[:workspace_key]).first

    if @workspace and annotable? @workspace
      @article = Article.new
      render :partial => 'new'
    else
      render :partial => "shared/unauthorized"      
    end
  end
  
  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
    @workspace = Workspace.where(:key => params[:workspace_key]).first
    if @workspace and annotable? @workspace 
      articles = @workspace.articles
      if params[:pmids]
        nber_before = articles.size
        Fetch.load_articles(params[:pmids].split(/[\s,;]+/), @workspace, current_user)
        nber_after = articles.size
        redirect_to workspace_path(:key => @workspace.key), notice: "#{nber_after - nber_before} articles were successfully created"
      else
        @article = Article.new(article_params)
        @article.num = (articles.size > 0) ? (articles.sort.last.num + 1) : 1
        respond_to do |format|
          if @article.save
            format.html { redirect_to @article, notice: 'Article was successfully created.' }
            format.json { render :show, status: :created, location: @article }
          else
            format.html { render :new }
            format.json { render json: @article.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      render :partial => "shared/unauthorized"
    end
  end
  
  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if (admin? or annotable? @workspace) and @article.update(article_params)
       
        format.html { 
          if params[:partial] == 'attr'
            render :partial => 'show_attribute', :locals => {:article_attr => @article.attributes, :attr => params[:attr_name]}
          else
              redirect_to article_path(:key => @article.key), notice: 'Article was successfully updated.'
          end
        }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    if admin? or annotable? @workspace 
      @article.update_attribute(:obsolete => true)
      #   if @article.assertions.size > 0
      #     @article.assertions.each do |a|
      #       a.assertion_versions.delete_all
      #       a.rels.delete_all
      #     end
      #     @article.assertions.delete_all
      #   end
      #   @article.destroy
    end
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_article
    @article = Article.find_by_key(params[:key])
    @workspace = @article.workspace
    @attachment_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'attachments' + @workspace.key
    @h_assessment_types = {}
    AssessmentType.all.map{|at| @h_assessment_types[at.id] = at}
    
    @h_assertion_types = {}
    @h_assertion_types_by_name = {}
    AssertionType.all.map{|at| 
      @h_assertion_types[at.id] = at
      @h_assertion_types_by_name[at.name]= at
    }
      
    @h_assertions = {}     
    @h_assertion_ids_by_type = {}
   # @h_nber_assertion_versions ={}
#    @h_last_assertion_version = {}
    
    assertions = Assertion.where(:article_id => @article.id, :obsolete => false).all.sort{|a, b| a.rank <=> b.rank}
    assertions.each do |a|
      @h_assertions[a.id] = a
    
      @h_assertion_ids_by_type[@h_assertion_types[a.assertion_type_id].name.to_sym] ||= []
      @h_assertion_ids_by_type[@h_assertion_types[a.assertion_type_id].name.to_sym].push a.id
   #   @h_nber_assertion_versions[a.id] = 0
    #  @h_last_assertion_version[a.id] = nil
    end
    
    # @h_nber_assertion_versions ={}
    #  @h_assertion_versions = {}
    @h_last_assertion_version = {}
    
    assertion_versions = AssertionVersion.where(:assertion_id => assertions.map{|a| a.id}).order('created_at desc').all
    assertion_versions.each do |av|
      @h_last_assertion_version[av.assertion_id] = av if !@h_last_assertion_version[av.assertion_id]
    end
    
    @h_rel_types = {}
    RelType.all.map{|rt| 
      @h_rel_types[rt.id] = rt
      @h_rel_types[rt.name] = rt
    }
    
    assertion_ids = assertions.map{|a| a.id}
    @h_rels = {:by_compl => {}, :by_subj => {}}
  #  @h_rels ={}
    Rel.joins("join assertions on (subject_id = assertions.id)").where("assertions.obsolete is false and complement_id in (?)", assertion_ids).order("assertions.rank asc").all.each do |rel|
     # @h_rels[rel.id] = rel
      @h_rels[:by_compl][@h_rel_types[rel.rel_type_id].name]||={}
      @h_rels[:by_compl][@h_rel_types[rel.rel_type_id].name][rel.complement_id] ||=[]
      @h_rels[:by_compl][@h_rel_types[rel.rel_type_id].name][rel.complement_id].push rel.subject_id
 #     @h_rels[:by_subj][@h_rel_types[rel.rel_type_id].name]||={}
 #     @h_rels[:by_subj][@h_rel_types[rel.rel_type_id].name][rel.subject_id] ||=[]
 #     @h_rels[:by_subj][@h_rel_types[rel.rel_type_id].name][rel.subject_id].push rel.complement_id
    end
    
  end
  
  
  
  # Never trust parameters from the scary internet, only allow the white list through.
  def article_params
    params.fetch(:article).permit(:pmid, :additional_context, :references_txt, :large_scale)
  end
end
