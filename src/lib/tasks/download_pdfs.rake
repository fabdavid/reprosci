desc "Download PDFs for a list of PubMed IDs"
task download_pdfs: :environment do
  
  def main pubmed_ids
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari' # Mimic a real browser    
    pubmed_ids.each do |pubmed_id|
      url = "https://pubmed.ncbi.nlm.nih.gov/#{pubmed_id}/"
      page = agent.get(url)

      #      puts page.links #.to_json
      
      # Find the DOI from the page
      doi = find_doi(page)
      
      if doi
        # Construct the DOI URL
        doi_url = "https://doi.org/#{doi}"
        agent.request_headers = {
          "Referer" => doi_url,
          "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36",
          "Accept-Language" => "en-US,en;q=0.9",
          "Connection" => "keep-alive"
        }
        doi_page = agent.get(doi_url)

        # Attempt to handle interstitial pages or redirections
        File.write("doi_page.html", doi_page.body)
#        exit
        if doi_page.body.include?("Redirecting") || doi_page.body.include?("continue")
          puts "sleep for 2 sec"
          sleep(2) # simulate wait for redirection
          doi_page = agent.page.link_with(text: /continue/i).click rescue doi_page
        end

        # Check if it's a JavaScript redirection page
          if doi_page.body.include?("autoRedirectToURL")
            redirect_url = extract_redirect_url(doi_page)
            agent.request_headers["Referer"] = doi_url
            doi_page = agent.get(redirect_url) if redirect_url
          end
          
      #  puts doi_page.body
      #  exit
        # Find the PDF link on the publisher's page
        pdf_link = find_pdf_link_on_publisher_page(doi_page)
        
        if pdf_link
          # Download and save the PDF
          pdf_page = agent.click(pdf_link)
          filename = Pathname.new(APP_CONFIG[:data_dir]) + 'pdfs' + "#{pubmed_id}.pdf"
          pdf_page.save(filename)
          puts "Downloaded: #{filename}"
        else
          puts "PDF not found on the publisher's site for DOI: #{doi}"
        end
      else
        puts "DOI not found for PubMed ID: #{pubmed_id}"
      end
    rescue => e
        puts "An error occurred for PubMed ID #{pubmed_id}: #{e.message}"
    end
   end

    def extract_redirect_url(page)
    # Extract the URL from the hidden input field in the JavaScript code
redirect_url_node = page.at('input#redirectURL')
  redirect_url = redirect_url_node ? CGI.unescape(redirect_url_node['value']) : nil
  redirect_url
  end
   
   def find_doi(page)
    # Extract the DOI from the page, typically found in the citation section
    doi_node = page.at('meta[name="citation_doi"]')
    doi_node ? doi_node['content'] : nil
   end
   
   #  def find_pdf_link page
   #    # This is a simplistic example. The actual implementation may need to be more complex
   #    # depending on how the PDFs are linked on the page.
   #    link = page.link_with(text: /Full Text PDF|Download PDF|PDF/i)
   #    link ||= page.link_with(href: /.*\.pdf$/i)
   #    link
   #  end
   
   def find_full_text_link(page)
     # Look for the "Full text links" section
     link = page.link_with(text: /Full text links/i)
     link
   end
   
   def find_pdf_link_on_publisher_page(page)
     # Try to find a PDF link on the publisher's page
     # This might need to be adjusted based on the structure of the publisher's site
     link = page.link_with(text: /PDF/i)
     link ||= page.link_with(href: /.*\.pdf$/i)
     link
   end
   
   pubmed_ids = Article.all.map{|a| a.pmid}
   main(pubmed_ids)
   
   
end
