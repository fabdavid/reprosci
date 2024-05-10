class AuthorsController < ApplicationController
  before_action :set_author, only: %i[ show edit update destroy ]
  
  def upd_create

#    h_sex = {
#      '1' => true,
#      '0' => false,
#      '' => nil
#    }
    params[:author][:sex] = h_sex[params[:author][:sex]]
    @author =  Author.where(:article_id => params[:author][:article_id], :name => params[:author][:name]).first
    if !@author
      @author = Author.where(author_params).new
      @author.save
    else
      @author.update_attributes(author_params)
    end

    render :partial => 'upd_list'
  end

  
  # GET /authors or /authors.json
  def index
    @h_career_stages = {}
    CareerStage.all.map{|e| @h_career_stages[e.id] = e}
    @h_expertise_levels = {}
    ExpertiseLevel.all.map{|e| @h_expertise_levels[e.id] = e}

    if params[:article_id]
      article = Article.where(:id => params[:article_id]).first
      @authors = article.authors
    else
      @authors = Author.all
    end
    render :partial => "index"
  end

  # GET /authors/1 or /authors/1.json
  def show
  end

  # GET /authors/new
  def new
    @author = Author.new
  end

  # GET /authors/1/edit
  def edit
  end

  # POST /authors or /authors.json
  def create
    @author = Author.new(author_params)

    respond_to do |format|
      if @author.save
        format.html{ render :partial => 'upd_list'}
#        format.html { redirect_to author_url(@author), notice: "Author was successfully created." }
#        format.json { render :show, status: :created, location: @author }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authors/1 or /authors/1.json
  def update
    respond_to do |format|
      if @author.update(author_params)
        format.html{ render :partial => 'upd_list'}
 #       format.html { redirect_to author_url(@author), notice: "Author was successfully updated." }
 #       format.json { render :show, status: :ok, location: @author }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authors/1 or /authors/1.json
  def destroy
    @author.destroy

    respond_to do |format|
      format.html { redirect_to authors_url, notice: "Author was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author
      @author = Author.find(params[:id]) if params[:id]
    end

    # Only allow a list of trusted parameters through.
    def author_params
      params.fetch(:author).permit(:name, :first_author, :leading_author, :sex, :expertise_level_id, :career_stage_id, :article_id)
    end
end
