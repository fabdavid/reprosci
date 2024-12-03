desc '####################### Get citing articles'
task get_citing_articles: :environment do
  puts 'Executing...'

  now = Time.now

  # Step 1: Get citing PMIDs using elink
  def get_citing_articles(pubmed_id)
#    puts "get citing articles"
    url = URI("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=pubmed&id=#{pubmed_id}&cmd=neighbor&linkname=pubmed_pubmed_citedin")
    response = Net::HTTP.get(url)
 
    # Parse XML using Hpricot
    doc = Hpricot(response)
    citing_pmids = []

    
    #    (doc/"LinkSet LinkSetDb").each do |linkset|
    #      puts linkset
    #      if (linkset/"LinkName").text == 'pubmed_pubmed_citedin'
    #        (linkset/"Link/Id").each do |id|
    #          citing_pmids << id.inner_html
    #        end
    #      end
    #    end
    # Debugging: Print the document to see its structure
#    puts "Document Structure:"
#    puts doc.to_s
    
    # Accessing LinkSetDb directly under LinkSet
    (doc/"linksetdb").each do |linkset|
      # Debugging: Print each LinkSetDb to ensure it's being accessed
#      puts "LinkSetDb Structure:"
#      puts linkset.to_s
      
      if (linkset/"linkname").inner_html == 'pubmed_pubmed_citedin'
        (linkset/"id").each do |id|
          citing_pmids << id.inner_html
        end
      end
    end
#    puts citing_pmids.to_json
    citing_pmids
  end
  
#  # Step 2: Get publication details (including year) using esummary
#  def get_article_details(pmids)
#    #    ids = pmids.join(',')
#    #    url = URI("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=#{ids}&retmode=json")
#    #    response = Net::HTTP.get(url)
#    #    details = JSON.parse(response)
#    #   details['result']
#    pmids.each_slice(100) do |pmid_chunk|
#      ids = pmid_chunk.join(',')
#      url = URI("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=#{ids}&retmode=json")
#      response = Net::HTTP.get(url)
#      
#      # Check if response is JSON, otherwise handle the error
#      begin
#        details = JSON.parse(response)
#      rescue JSON::ParserError
#        puts "Error parsing response for PMIDs: #{pmid_chunk.join(', ')}"
#        next
#      end
#      
#      details['result'].each do |pmid, info|
###        yield pmid, info if pmid != 'uids'
#      end
#    end
#  end
  
##  # Step 3: Organize PMIDs by year of publication
##  def organize_pmids_by_year(pubmed_id)
#    citing_articles = get_citing_articles(pubmed_id)
#    details = get_article_details(citing_articles)
#    
#    pmids_by_year = {} #Hash.new { |hash, key| hash[key] = [] }
###    if details
#      details.each do |pmid, info|
#        next if pmid == 'uids' # Skip the 'uids' key in the JSON response
##        
#        pubdate = info['pubdate']
#        year = pubdate.split(' ').first # Extract the year from the publication date
#        pmids_by_year[year] ||= []
#        pmids_by_year[year] << pmid
#      end
#    end
#    pmids_by_year
#  end

  # Step 2: Get publication details (including year) using esummary in chunks
  def get_article_details(pmids)
    pmids_by_year = Hash.new { |hash, key| hash[key] = [] }
    
    pmids.each_slice(100) do |pmid_chunk|
      ids = pmid_chunk.join(',')
      url = URI("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=#{ids}&retmode=json")
      response = Net::HTTP.get(url)
      
      # Check if response is JSON, otherwise handle the error
      begin
        details = JSON.parse(response)
      rescue JSON::ParserError
        puts "Error parsing response for PMIDs: #{pmid_chunk.join(', ')}"
        next
      end
      
      details['result'].each do |pmid, info|
        next if pmid == 'uids' # Skip the 'uids' key in the JSON response
        
        pubdate = info['pubdate']
        year = pubdate.split(' ').first # Extract the year from the publication date
        pmids_by_year[year] << pmid
      end
    end
    
    pmids_by_year
  end
  
  # Step 3: Organize PMIDs by year of publication
  def organize_pmids_by_year(pubmed_id)
    citing_articles = get_citing_articles(pubmed_id)
    pmids_by_year = get_article_details(citing_articles)
    pmids_by_year
  end
  
  
  # Example usage
  h_res = {}
  articles = Article.all
  articles.each do |a|
    #pmid = 8808632
    puts a.pmid
    pubmed_id = a.pmid
    h_res[pubmed_id] = organize_pmids_by_year(pubmed_id)
    sleep 3
  end
  
  File.open(Pathname.new(APP_CONFIG[:data_dir]) + 'citations.json', 'w') do |f|
    f.write(h_res.to_json)
  end
  
end
