desc "Create txt form pdfs and map PDFs for a list of PubMed IDs"
task map_pdf: :environment do

  def extract_text_from_pdf(pdf_path, txt_path)
    # Make a system call to `pdftotext` to extract text
   # text_file = "temp_text.txt"
    cmd = "pdftotext #{pdf_path} #{txt_path}"
    puts cmd
    system(cmd)
    
    # Read the extracted text from the temporary file
    text = File.read(txt_path)
    
    # Clean up the temporary text file
    #    File.delete(text_file) if File.exist?(text_file)
    
#    text
  end

  def find_doi(page)
    # Extract the DOI from the page, typically found in the citation section        
    doi_node = page.at('meta[name="citation_doi"]')
    doi_node ? doi_node['content'] : nil
  end
  
  def figures_panels_tables(pdf_path)
    # Extract text from the PDF
    text = extract_text_from_pdf(pdf_path)

    doi_pattern = /doi:(.+?)/
    doi = text.scan(doi_pattern)
    
    # Regular expressions to find figures, panels, and tables
    figure_pattern = /(Figure\s?\d+|Fig.\s?\d+)/i   # Matches 'Figure 1', 'Fig. 1', etc.
    panel_pattern = /([A-Z]\))/                     # Matches 'A)', 'B)', etc., typical for panels
    table_pattern = /(Table\s?\d+)/i                # Matches 'Table 1', 'Table 2', etc.
    
    # Find all matches for figures, panels, and tables
    figures = text.scan(figure_pattern).uniq        # Unique matches for figures
    panels = text.scan(panel_pattern)               # Panels are counted directly
    tables = text.scan(table_pattern).uniq          # Unique matches for tables
    
    return doi, figures, panels, tables
  end
  

  #update doi
  puts "update doi for all articles..."
  agent = Mechanize.new
  agent.user_agent_alias = 'Mac Safari' # Mimic a real browser       
  Article.all.each do |a|
    if !a.doi
      url = "https://pubmed.ncbi.nlm.nih.gov/#{a.pmid}/"
      page = agent.get(url)
      doi = find_doi(page)
      a.update_attribute(:doi, doi)
    end
  end

  # create txt files
  
  pdf_dir = Pathname.new(APP_CONFIG[:share_data_dir]) + 'repro_pdfs_400'
  txt_dir = Pathname.new(APP_CONFIG[:share_data_dir]) + 'repro_pdfs_400_txt'
   Dir.entries(pdf_dir).select{|e| e.match(/[\._]pdf$/)}.each do |filename|
    corrected_filename = filename.gsub(/[^\w\d_\-]+/, "_").gsub(/_pdf$/, '.pdf')
    pdf_path = pdf_dir + filename
    corrected_pdf_path = pdf_dir + corrected_filename
    FileUtils.move pdf_path,  corrected_pdf_path if corrected_pdf_path != pdf_path
    txt_path = txt_dir + corrected_filename.gsub(/\.pdf$/, '.txt')

    if !File.exist? txt_path
      extract_text_from_pdf(corrected_pdf_path, txt_path)
    end
    
   # begin
    #  # Get the counts of figures, panels, and tables
    #  num_figures, num_panels, num_tables = count_figures_panels_tables(pdf_path)
    #  
    #  # Output the results
    #  puts "Figures: #{num_figures.join(",")}"
    #  puts "Panels: #{num_panels.join(",")}"
    #  puts "Tables: #{num_tables.join(",")}"
    #rescue => e
     # puts "Error processing the PDF: #{e.message}"
   # end
  end

   not_found = []
   
   Article.all.select{|a| !a.pdf_txt_filename }.each do |a|
     puts [a.pmid, a.authors_txt].join(", ")
     t = a.title.split(" ")
     start_title = (1 .. 5).map{|i| (t[i]) ? t[i].gsub(/[^\w]/, ".+?") : nil}.compact.join("[[:space:]\\r]+")
     shell_script = "for file in #{txt_dir}/*; do \
    head -n 20 \"$file\" | grep -Eiqz \"#{start_title}\" && echo \"$file\"; \
    done"
     puts shell_script
     res = `#{shell_script}`
    
     if res.split("\n").size ==1
       puts "#{a.id} => #{res}"
       a.update_attribute(:pdf_filename, res.gsub(/repro_pdfs_400_txt/, "repro_pdfs_400").gsub(/\.txt$/, ".pdf"))
       a.update_attribute(:pdf_txt_filename, res)
     elsif res.split("\n").size >1
       puts res.split("\n")
       puts "!!!!!!!!!!!!!!!!!!!!!Too many results!!!!!!!!!!!!!!!!!!!!!"
     else
       puts "!!!!!!!!!!!!!!!!!!!!!No result!!!!!!!!!!!!"
       not_found.push [a.pmid, a.authors_txt, a.title]
       
     end
   end

   filename = "/mnt/reprosci_share/missing_pdfs.txt"
   File.open(filename, 'w') do |f|
     not_found.each do |e|
       f.write e.join("\t") + "\n"
     end
   end
  
end
