  module Fetch
    
    class << self

    def load_articles pmids, workspace, user
      
      #      ActiveRecord::Base.transaction do
     
      
      pmids.each do |pmid|
        puts pmid
        h_article = Fetch.fetch_pubmed(pmid)
        h_article[:workspace_id] = workspace.id
        
        puts h_article.to_json
        article = Article.where(:pmid => pmid).first
        
        if !article
          h_article[:user_id] = user.id
          h_article[:orcid_user_id] = user.orcid_user_id
          h_article[:key] = Basic.create_key(Article, 6)
          articles = workspace.articles
          h_article[:num] = (articles.size > 0) ? (articles.sort.last.num + 1) : 1 
          article = Article.new(h_article)
          
          article.save
        else
          article.update_attributes(h_article)
        end
      end
      #      end
    end
    
    def fetch_pubmed(pmid)
      
      require 'hpricot'
      require 'open-uri'
      
      doc = open("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=#{pmid}&retmode=xml") { |f| Hpricot(f) }
      p_article = doc.at("pubmedarticle")
      results = nil
      if p_article
        citation= p_article.at("medlinecitation")
        article = citation.at("article")
        results = {:pmid => pmid}
        journal_node = article.at("journal")
        if journal_node
          journal_title = journal_node.at("title").innerHTML
          journal = Journal.where(:name => journal_title).first
          if !journal
            journal = Journal.new(:name => journal_title)
            journal.save
          end
          results[:journal_id] = journal.id
          if journal_issue = journal_node.at("journalissue")
            results[:volume] = journal_issue.at("volume").innerHTML if journal_issue.at("volume")
            results[:issue] = journal_issue.at("issue").innerHTML if journal_issue.at("issue")
            pubdate = journal_issue.at("pubdate")
            results[:year]=''
            if pubdate.at("year")
              results[:year]=pubdate.at("year").innerHTML
            elsif pubdate.at("medlinedate")
              results[:year]=pubdate.at("medlinedate").innerHTML.split(" ").first
            end
          end
        end
        results[:title]=article.at("articletitle").innerHTML
        authors = article.at("authorlist").search("author")
        all_authors = []
        all_affs = []
        authors.each do |a|
          affs = []
          if a.at("affiliationinfo")
            affs = a.at("affiliationinfo").search("affiliation").map{|e| e.innerHTML}            
          end
          puts affs
          all_affs.push(affs)
          all_authors.push(((a.at("lastname")) ? a.at("lastname").innerHTML : '') + " " + ((a.at("initials")) ?  a.at("initials").innerHTML : ''))
        end
        results[:authors]=all_authors.join(";")
        results[:affs_json] = all_affs.to_json
        #    results[:authors]+= " et al." if authors.size > 1                                                                                      
        abstract = article.at("abstract")
        results[:abstract]=abstract.at("abstracttext").innerHTML if abstract
      end
      return results
      
    end
  end

end
