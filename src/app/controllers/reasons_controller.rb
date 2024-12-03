class ReasonsController < ApplicationController
  before_action :set_reason, only: %i[ show edit update destroy ]

  # GET /reasons or /reasons.json
  def index
    if read_admin?
      @reasons = Reason.all
    else
      @reasons = []
    end

    @reason_types = ReasonType.all
    
    respond_to do |format|
       format.html {
       }
       format.text {
         t = []
         header = ['article', 'challenged_claim', 'claim_type', 'assessment_type', 'assessment'] + @reason_types.map{|rt| rt.name} + ['comment']
         t.push header
         @reasons.each do |reason|
           
           #    <td><%= raw display_ref(article) %></td>
           #      <td><%= raw display_assertion(complement, complement.assertion_type) %></td>
           #      <td><%= raw complement.assertion_type.label %></td>
           #      <td><%= subject.assessment_type.name %></td>
           #      <td><%= raw display_assertion(subject, subject.assertion_type) %><br/>
           subject = reason.assertion
           rel = reason.rel
           complement = Assertion.where(:id => rel.complement_id).first
           article = subject.article

           authors = article.authors_txt.split(";")
           article_txt = authors.first + ((authors.size > 1) ? '<i> et al.</i>' : '') + ", " + article.year.to_s
           reason_type_ids = reason.reason_type_ids || ''
           l = [
             article_txt,
             #             complement.content,
             helpers.display_assertion_txt(complement, complement.assertion_type),
             complement.assertion_type.name,
             subject.assessment_type.name,
             #subject.content
             helpers.display_assertion_txt(subject, subject.assertion_type),
           ] +  @reason_types.map{|rt| (reason_type_ids.split(",").include? rt.id.to_s) ? "Yes" : "-"} + [reason.comment]
           t.push l
         end
         render :plain => t.map{|e| e.join("\t")}.join("\n")
       }
    end
    
  end

  # GET /reasons/1 or /reasons/1.json
  def show
  end

  # GET /reasons/new
  def new
    @reason = Reason.new
  end

  # GET /reasons/1/edit
  def edit
  end

  # POST /reasons or /reasons.json
  def create
    @reason = Reason.new(reason_params)

    respond_to do |format|
      if read_admin? and @reason.save
        format.html {
          #redirect_to reason_url(@reason), notice: "Reason was successfully created."
#          render :partial => "update"
        }
        format.json { render :show, status: :created, location: @reason }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reason.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reasons/1 or /reasons/1.json
  def update

    @reason.user_id = current_user.id
    respond_to do |format|
      if read_admin? and @reason.update(reason_params)
        format.html {
          
          #redirect_to reason_url(@reason), notice: "Reason was successfully updated."
          render :partial => "update"
        }
        format.json { render :show, status: :ok, location: @reason }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reason.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reasons/1 or /reasons/1.json
  def destroy
    @reason.destroy if read_admin?

    respond_to do |format|
      format.html { redirect_to reasons_url, notice: "Reason was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reason
      @reason = Reason.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def reason_params
      params.fetch(:reason).permit(:reason_type_ids, :comment)
    end
end
