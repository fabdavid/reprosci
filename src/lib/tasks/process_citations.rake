desc '####################### Process citations'
task process_citations: :environment do
  puts 'Executing...'

  now = Time.now
  
  h_groups2 = {
    "Verified" => ["Verified", "Verified by same authors", "Verified by reproducibility project"],
    "Unchallenged" => ["Unchallenged, logically consistent", "Unchallenged, logically inconsistent", "Unchallenged"],
    "Challenged" => ["Challenged", "Challenged by same authors", "Challenged by reproducibility project"],
    "Partially verified" => ["Partially verified"],
    "Mixed" => ["Mixed"],
    "In progress" => ["Reproduction in progress"]
  }


  list_groups2 = ["Unchallenged", "Verified", "Partially verified", "Mixed", "In progress", "Challenged" ]

  citation_file = Pathname.new(APP_CONFIG[:data_dir]) + 'citations.json'
  h_citations = JSON.parse(File.read(citation_file))
  
  res = []

  header = ["Article ID", "PMID", "First author", "First author sex", "First author career stage", "First author expertise level", "Last author", "Last author sex", "Last author career stage", "Last author expertise level", "Authors", "Year", "Title", "# major claims", "Unchallenged", "Verified", "Partially verified", "Mixed", "In progress", "Challenged", "% challenged", "# panels", "# tables"] + (0 .. 10).to_a.map{|i| "Citations (year+#{i})"}
  res.push header
  Article.all.each do |a|
    citations = h_citations[a.pmid.to_s]
    if citations
      fa = a.authors.select{|e| e.first_author == true}.first
      la = a.authors.select{|e| e.leading_author == true}.first
      major_claims = a.assertions.select{|assert| assert.assertion_type_id == 2 and assert.obsolete == false }
      h_r = {}
      list_groups2.each do |g|
        h_r[g] = major_claims.select{|e| at = e.assessment_type and h_groups2[g].include? at.name}.size
      end
      res.push([a.id, a.pmid] +
               ((fa) ? [fa.name, fa.sex, fa.career_stage.name, fa.expertise_level.name] : ["", "", "", ""]) +
               ((la) ? [la.name, la.sex, la.career_stage.name, la.expertise_level.name] : ["", "", "", ""]) +
               [a.authors_txt, a.year, a.title, major_claims.size] + list_groups2.map{|g| h_r[g]} +
               [a.nber_panels || 0, a.nber_tables || 0] + 
               (0 .. 10).to_a.map{|i| (citations[(a.year + i).to_s]) ? citations[(a.year + i).to_s].size : 0})
    else
      puts "Cannot find citations for #{a.pmid}"
    end
  end
  
  
  File.open(Pathname.new(APP_CONFIG[:data_dir]) + 'citation_counts.txt', 'w') do |f|
    res.each do |e|
      f.write(e.join("\t") + "\n")
    end
  end
  
end
