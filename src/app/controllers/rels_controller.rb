class RelsController < ApplicationController
  before_action :set_rel, only: [:show, :edit, :update, :destroy]

  # GET /rels
  # GET /rels.json
  def index
    @rels = Rel.all
  end

  # GET /rels/1
  # GET /rels/1.json
  def show
  end

  # GET /rels/new
  def new
    if params[:article_key] and params[:complement_id] and params[:rel_type_id]
      @article = Article.where(:key => params[:article_key]).first
      @workspace = @article.workspace
      if (params[:rel_type_id] == '3' and commentable? @workspace) or annotable? @workspace 
        @complement = Assertion.where(:article_id => @article.id, :id => params[:complement_id]).first
        @rel_type = RelType.where(:id => params[:rel_type_id]).first
        @subject_type = AssertionType.where(:id => @rel_type.subject_type_id).first
        if @complement and @rel_type
          @rel = Rel.new(:complement_id => @complement.id, :rel_type_id => @rel_type.id)
          @complement_type = @complement.assertion_type 
          #    @assertion_type = AssertionType.where(:id => params[:assertion_type_id]).first
          render :partial => "new"
        else
          render :partial => 'shared/invalid'
        end
      else
        render :partial => "shared/unauthorized"
      end
    else
      render :partial => 'shared/invalid'
    end
  end

  # GET /rels/1/edit
  def edit
  end

  # POST /rels
  # POST /rels.json
  def create
    @rel = Rel.new(rel_params)
    
    if params[:article_key] and params[:content] and params[:subject_type_id]
      @article = Article.where(:key => params[:article_key]).first
      @workspace = @article.workspace
      @subject_type = AssertionType.where(:id => params[:subject_type_id]).first

      ## check doi if exists
      valid_pmid = 0
      if params[:pmid] and params[:pmid].strip != ''
        res = Fetch.fetch_pubmed(params[:pmid])
        if res[:title] and res[:title] != ''
          valid_pmid = 1
        end
      end

      ## create subject
      h_subject= {
        :content => params[:content],
        :ext => (params[:file]) ? params[:file].original_filename.split(".").last : nil,
        :assertion_type_id => params[:subject_type_id],
        :assessment_type_id => (params[:assessment_type_id]) ? params[:assessment_type_id] : nil, 
        :article_id => @article.id,
        :user_id => current_user.id,
        :orcid_user_id => current_user.orcid_user_id,
        :rank => Assertion.where(:article_id => @article.id, :assertion_type_id => @subject_type.id).count + 1,
        :all_tags_json => params[:all_tags_json],
        :pmid => (valid_pmid == 1) ? params[:pmid].strip : nil
      }
      @subject = Assertion.new(h_subject)
      @subject.save      

      Basic.upd_tags(@subject)

      if (commentable? @workspace and @subject.assertion_type_id == 7) or annotable? @workspace
        @rel.user_id = current_user.id
        @rel.orcid_user_id = current_user.orcid_user_id
        @rel.subject_id = @subject.id
        
     #   @assertion.content_modified_at = Time.now                                                                                                                                                              
        respond_to do |format|
          if @rel.save

            Basic.upd_workspace_stats @workspace

            #save file if there is one          
            if params[:file]
              attachment_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'attachments' + @workspace.key
              Dir.mkdir(attachment_dir) if !File.exist?(attachment_dir)
              filepath = attachment_dir + (@subject.id.to_s + "." + @subject.ext.gsub(/[^\w\d]+/, '_'))
              File.open(filepath, 'wb') do |f|
                f.write(params[:file].read())
              end
            end

            h_subject_version = {
              :content => @subject.content,
              :all_tags_json => @subject.all_tags_json,
              :assertion_id => @subject.id,
              :user_id => current_user.id,
              :orcid_user_id => current_user.orcid_user_id
            }
            assertion_version = AssertionVersion.new(h_subject_version)
            assertion_version.save

            ### create subject's assessment
            if @subject.assertion_type.is_assessed == true
              as = Assertion.new(:assertion_type_id => 6, :content => '', :rank => 1, :article_id => @article.id, :assessment_type_id => 5, :user_id => current_user.id, :orcid_user_id => current_user.orcid_user_id)
              as.save
              as_v = AssertionVersion.new({:assertion_id => as.id, :content => '', :version => 1, :user_id => current_user.id, :orcid_user_id => current_user.orcid_user_id})
              as_v.save
              rel = Rel.new(:subject_id => as.id, :user_id => current_user.id, :orcid_user_id => current_user.orcid_user_id, :complement_id => @subject.id, :rel_type_id => 2)
              rel.save
            end

            @rel_type = @rel.rel_type
            @complement = Assertion.where(:id => @rel.complement_id).first
            @nber_rels =  Rel.joins('join assertions on (assertions.id = subject_id)').where(:complement_id => @complement.id, :rel_type_id => @rel_type.id, :assertions => {:obsolete => false}).count()
            #Rel.where(:rel_type_id => @rel_type.id, :obsolete => false, :complement_id => @complement.id).count()
            @to_refresh_assertion_type = (@subject_type.refresh_side_panel == true) ? @subject_type : @complement.assertion_type
            

            format.html { render :partial => 'create' }
            format.json { render :show, status: :created, location: @rel }
          else
            format.html { render :partial => 'shared/error', :locals => {:error => @rel.errors } }
            format.json { render json: @rel.errors, status: :unprocessable_entity }
          end
        end
      else
        render :partial => 'shared/unauthorized'
      end
    else
      render :partial => 'shared/invalid'
    end

    #    @rel = Rel.new(rel_params)
    #
    #    respond_to do |format|
    #      if @rel.save
    #        format.html { redirect_to @rel, notice: 'Rel was successfully created.' }
    #        format.json { render :show, status: :created, location: @rel }
    #      else
    #        format.html { render :new }
    #        format.json { render json: @rel.errors, status: :unprocessable_entity }
    #      end
    #    end
  end

  # PATCH/PUT /rels/1
  # PATCH/PUT /rels/1.json
  def update
    respond_to do |format|
      if @rel.update(rel_params)
        format.html { redirect_to @rel, notice: 'Rel was successfully updated.' }
        format.json { render :show, status: :ok, location: @rel }
      else
        format.html { render :edit }
        format.json { render json: @rel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rels/1
  # DELETE /rels/1.json
  def destroy
    @rel.destroy
    respond_to do |format|
      format.html { redirect_to rels_url, notice: 'Rel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rel
      @rel = Rel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rel_params
#      params.fetch(:rel, {})
        params.fetch(:rel).permit(:complement_id, :rel_type_id)

    end
end
