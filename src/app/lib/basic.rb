module Basic

  #class Basic                                                                  

  class << self

    def upd_workspace_stats workspace
      
      articles = workspace.articles.where(:obsolete => false)   
      nber_claims = Assertion.where(:obsolete => false, :assertion_type_id => [1, 2, 3], :article_id => articles.map{|e| e.id}).count
      nber_comments =  Assertion.where(:obsolete => false, :assertion_type_id => 7, :article_id => articles.map{|e| e.id}).count
      workspace.update_attributes(:nber_articles => articles.count, :nber_claims => nber_claims, :nber_comments => nber_comments)
      
    end

    
    def upd_tags assertion
      
      assertion.tags.clear
      assertion.genes.clear
      
      if assertion.all_tags_json and !assertion.all_tags_json.empty?
        all_tags = Basic.safe_parse_json(assertion.all_tags_json, [])
        h_genes = {}
        genes = Gene.where(:id => all_tags.select{|tag| tag['type']=='gene'}.map{|tag| tag['id']}).all
        genes.each do |g|
          assertion.genes << g if !assertion.genes.include? g
        end
        all_tags.each do |tag|
          if ['tag', 'hidden'].include? tag['type']# == 'tag'
            h_tag = {
              :name => tag['val']
            }
            t = Tag.where(h_tag).first
            if !t
              t = Tag.new(h_tag)
              t.save
            end
            assertion.tags << t if !assertion.tags.include? t
          end
        end
      end
      
    end

    def safe_parse_json2 json, default
      h = default
      begin
        h = JSON.parse json, object_class: OpenStruct
      rescue
      end
      return h
    end
    
    def safe_parse_json json, default
      h = default
      begin
        h = JSON.parse json
      rescue
      end
      return h
    end
    
    def create_key model, n
      tmp_key = Array.new(n){[*'0'..'9', *'a'..'z'].sample}.join
      if model
        while model.where(:key => tmp_key).count > 0
          tmp_key = Array.new(n){[*'0'..'9', *'a'..'z'].sample}.join
        end
      end
      return tmp_key
    end
  end
end
