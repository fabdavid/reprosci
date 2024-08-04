class GenesController < ApplicationController
  before_action :set_gene, only: [:show, :edit, :update, :destroy]


  def autocomplete

    organism_id = nil
    if params[:organism] != ''
      organism_id = Organism.where(["lower(short_name) = ? or tax_id = ?", params[:organism].downcase, params[:organism]]).first.id
    elsif params[:article_key]
      article = Article.where(:key => params[:article_key]).first
      workspace = article.workspace
      organism_id = (workspace.organism_id) ? workspace.organism_id : article.organism_id
    end
    to_render = []
    final_list=[]
    h_genes = nil
    query = Gene.search do
      fulltext (params[:term].gsub(/\$\{jndi\:/, '').gsub(/[\{\}\$\:\\]/, '') + "*") do
      #  fields(:ensembl_id)
        fields(:alt_names, :name => 2.0, :ensembl_id => 3.0)
      end
      with :organism_id, organism_id if organism_id #params[:organism_id].to_i
#      order_by(:name, :asc)
#      limit 20
      paginate :page => 1, :per_page => 20
    end
    final_list = query.results
    
    to_render = final_list.map{|e| {:id => e.id, :label => "#{e.ensembl_id} #{e.name}" + ((e.alt_names.size > 0) ? " [" + e.alt_names.split(",").join(", ") + "]" : '')}}
    render :json => to_render.to_json
  end

  # GET /genes
  # GET /genes.json
  def index
    @genes = Gene.all
  end

  def search

    if params[:workspace_key] 
      @workspace = Workspace.where(:key => params[:workspace_key]).first
    end

    if params[:id]
      @gene = Gene.where(:id => params[:id]).first
    elsif params[:ensembl_id]
      @gene = Gene.where(:ensembl_id => params[:ensembl_id]).first
    end
    @h_extra_links = {
      35 => [['Flybase', "https://flybase.org/reports/" + @gene.ensembl_id + "'"]]
    }
    
    render :partial => "search"
  end

  # GET /genes/1
  # GET /genes/1.json
  def show
  end

  # GET /genes/new
  def new
    @gene = Gene.new
  end

  # GET /genes/1/edit
  def edit
  end

  # POST /genes
  # POST /genes.json
  def create
    @gene = Gene.new(gene_params)

    respond_to do |format|
      if admin? and @gene.save
        format.html { redirect_to @gene, notice: 'Gene was successfully created.' }
        format.json { render :show, status: :created, location: @gene }
      else
        format.html { render :new }
        format.json { render json: @gene.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /genes/1
  # PATCH/PUT /genes/1.json
  def update
    respond_to do |format|
      if admin? and @gene.update(gene_params)
        format.html { redirect_to @gene, notice: 'Gene was successfully updated.' }
        format.json { render :show, status: :ok, location: @gene }
      else
        format.html { render :edit }
        format.json { render json: @gene.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /genes/1
  # DELETE /genes/1.json
  def destroy
    @gene.destroy if admin?
    respond_to do |format|
      format.html { redirect_to genes_url, notice: 'Gene was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gene
      @gene = Gene.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gene_params
      params.fetch(:gene, {})
    end
end
