desc '####################### Compute stats by author'
task stats_by_author: :environment do
  puts 'Executing...'

  now = Time.now

  authors = Author.all

  h_articles = {}
  Article.all.map{|a| h_articles[a.id] = a}

  h_assessment_types = {}
  AssessmentType.all.map{|at| h_assessment_types[at.id] = at}

  h_groups = {
    "Verified" => ["Verified", "Verified by same authors"],
    "Verified by reproducibility project" => ["Verified by reproducibility project"],
    "Unchallenged" => ["Unchallenged, logically consistent", "Unchallenged, logically inconsistent", "Unchallenged"],
    "Challenged" => ["Challenged", "Challenged by same authors"],
    "Challenged by reproducibility project" => ["Challenged by reproducibility project"],
    "Partially verified" => ["Partially verified"],
    "Mixed" => ["Mixed"],
    "Others" => ["Reproduction in progress"]
  }
  
  h_groups2 = {
    "Verified" => ["Verified", "Verified by same authors", "Verified by reproducibility project"],
    "Unchallenged" => ["Unchallenged, logically consistent", "Unchallenged, logically inconsistent", "Unchallenged"],
    "Challenged" => ["Challenged", "Challenged by same authors", "Challenged by reproducibility project"],
    "Partially verified" => ["Partially verified"],
    "Mixed" => ["Mixed"],
    "In progress" => ["Reproduction in progress"]
  }

  
  list_groups2 = ["Unchallenged", "Verified", "Partially verified", "Mixed", "In progress", "Challenged"] #h_groups2.keys
  
  h_rev_groups = {}
  h_groups.keys.map{|k| h_groups[k].map{|k2| h_rev_groups[k2]=k}}
  h_rev_groups2 = {}
  h_groups2.keys.map{|k| h_groups2[k].map{|k2| h_rev_groups2[k2]=k}}
  
  
  h_authors = {}
  authors.each do |a|
    types = []
    types.push 'leading' if a.leading_author == true
    types.push 'first' if a.first_author == true
    types.each do |type|
      t = [a.name, a.sex, type, a.career_stage.name]
      h_authors[t] ||= []
      h_authors[t].push a.article_id
    end    
  end

  h_assertions = {}
  Assertion.all.map{|a| h_assertions[a.id] = a}

  fw = File.open(Pathname.new(APP_CONFIG[:data_dir]) + "stats_by_author.tsv", "w")
  header = ["Name", "Sex", "Type", "Career stage", "# articles", "# major claims"] + list_groups2
  fw.write header.join("\t") + "\n"

  fw2 = File.open(Pathname.new(APP_CONFIG[:data_dir]) + "lists_by_author.tsv", "w")
  header = ["Name", "Sex", "Type", "Career stage", "articles", "major claims"] + list_groups2
  fw2.write header.join("\t") + "\n"
  
  h_authors.each_key do |k|
    
    articles = h_authors[k].map{|a_id| h_articles[a_id]}
    assertions = articles.map{|a| a.assertions.select{|e| e.obsolete == false}}.flatten

    h_rels_by_type = {}
    assessement_type_by_claim_type = {}
    assertion_ids = assertions.map{|e| e.id}
    rels = Rel.where(:subject_id => assertion_ids, :complement_id => assertion_ids).all

    h_rels = {}
    rels.each do |rel|
      h_rels[rel.id] = rel
      subject = h_assertions[rel.subject_id]
      complement =  h_assertions[rel.complement_id]
      k1 = subject.assessment_type_id
      k2 = (complement) ? complement.assertion_type_id : nil
      k3 = subject.assertion_type_id
      h_rels_by_type[rel.complement_id] ||= {}
      h_rels_by_type[rel.complement_id][rel.rel_type_id] ||= []
      h_rels_by_type[rel.complement_id][rel.rel_type_id].push rel.id
      if k1 and rel.rel_type_id == 2
        assessement_type_by_claim_type[k2] ||= {}
        assessement_type_by_claim_type[k2][k1] ||= []
        assessement_type_by_claim_type[k2][k1].push(rel.complement_id) if !assessement_type_by_claim_type[k2][k1].include? rel.complement_id
      end
    end

    categories_data = []
#    h_nber_by_category = {}
    h_list_by_category = {}
    assessement_type_by_claim_type.each_key do |k1|
      tmp_h = {}
      assessement_type_by_claim_type[k1].each_key do |k2|
        tmp_h[h_rev_groups2[h_assessment_types[k2].name]] ||= []
        tmp_h[h_rev_groups2[h_assessment_types[k2].name]] |= assessement_type_by_claim_type[k1][k2]
      end
      h_list_by_category[k1] = tmp_h
      #  total = tmp_h.values.sum                                                                                                                                                                                  
    end
    
    
    
    major_claims = assertions.select{|a| a.assertion_type_id == 2}
    l = list_groups2.map{|e| (h_list_by_category[2][e]) ? h_list_by_category[2][e].size : 0}   #h_nber_by_category[2].keys.map{|e| }
    t = k + [h_authors[k].size, major_claims.size] + l
    l2 = list_groups2.map{|e| (h_list_by_category[2][e]) ? h_list_by_category[2][e].sort.join(",") : ''}
    t2 = k + [h_authors[k].sort.join(","), major_claims.map{|e| e.id}.sort.join(",")] + l2
    fw.write t.join("\t") + "\n"
    fw2.write t2.join("\t") + "\n"
  end

  fw.close
  fw2.close
  
  
end
