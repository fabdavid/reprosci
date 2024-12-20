desc "Download PDFs for a list of PubMed IDs"
task download_pdfs2: :environment do

  def fetch_doi_from_pmid(pmid)
    # Initialize Mechanize
    agent = Mechanize.new
    search_url = "https://pubmed.ncbi.nlm.nih.gov/#{pmid}/"
    
    # Fetch the PubMed page
    page = agent.get(search_url)
    
    # Extract the DOI
    doi_link = page.at('a[data-ga-action="DOI"]') #page.at('a[data-ga-category="full_text"')
    doi = doi_link['href'].split('doi.org/').last if doi_link
    doi
  end
  
 def download_pdf_from_doi(doi, pmid)
    # Initialize Selenium WebDriver
    driver = Selenium::WebDriver.for :firefox # or :chrome if using Chrome
    
    begin
      # Navigate to the DOI URL
      doi_url = "https://doi.org/#{doi}"
      driver.navigate.to doi_url
      
      # Wait for the page to load completely
      sleep(5) # Adjust sleep time as necessary
      
      # Handle potential JavaScript redirection
      if driver.current_url.include?('retrieve')
        redirect_url = driver.execute_script("return document.querySelector('input#redirectURL').value")
        redirect_url = URI.decode_www_form_component(redirect_url)
        driver.navigate.to redirect_url
      end
      
      # Wait for the redirected page to load
      sleep(5) # Adjust sleep time as necessary
      
      # Look for the PDF download link
      pdf_link = driver.find_elements(tag_name: 'a').find { |link| link.text =~ /PDF/i || link.attribute('href') =~ /.*\.pdf$/i }
      
      if pdf_link
        pdf_url = pdf_link.attribute('href')
        pdf_url = URI.join(driver.current_url, pdf_url).to_s
        
        # Download the PDF
        download_and_save_pdf(pdf_url, doi, pmid)
      else
        puts "PDF link not found for DOI: #{doi}"
      end

    ensure
      driver.quit
    end
  end

  def download_and_save_pdf(pdf_url, doi, pmid)
    filename = Pathname.new(APP_CONFIG[:data_dir]) + 'pdfs' + "#{pmid}.pdf"
    File.open(filename, "wb") do |file|
      file.write open(pdf_url).read
    end
    puts "Downloaded: #{filename}"
  end
  
  pmid_list = Article.all.map{|a| a.pmid}
  pmid_list.each do |pmid|
    begin
      doi = fetch_doi_from_pmid(pmid)
      if doi
        download_pdf_from_doi(doi, pmid)
      else
        puts "DOI not found for PubMed ID: #{pmid}"
      end
    rescue => e
      puts "An error occurred for PubMed ID #{pmid}: #{e.message}"
    end
  end

  
end
