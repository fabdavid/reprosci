desc "Analyze PDFs for a list of PubMed IDs"
task analyze_pdf: :environment do

  def panels_tables(txt_pdf_path)

#    text = File.read(txt_pdf_path.to_s)
    text = `less #{txt_pdf_path.to_s}`
    doi_pattern = /doi:(.+?)/
    doi = text.scan(doi_pattern)
    
    # Regular expressions to find figures, panels, and tables
    figure_pattern = /(Figure\s?\d+[\-.]?\w?|Fig\.\s?\d+[\-.]?\w?)/i   # Matches 'Figure 1', 'Fig. 1', etc.
# figure_pattern = /(Figure\s?\d+)/i   # Matches 'Figure 1', 'Fig. 1', etc.
    #    panel_pattern = /([A-Z]\))/                     # Matches 'A)', 'B)', etc., typical for panels
    table_pattern = /(Table\s?\d+)/i                # Matches 'Table 1', 'Table 2', etc.
    
    # Find all matches for figures, panels, and tables
    figures = text.scan(figure_pattern).flatten.map{|e| e.downcase.gsub(/\s+/, " ").gsub(/Fig\./, "Figure").gsub(/\.$/, "")}.uniq.sort        # Unique matches for figures
#    panels = text.scan(panel_pattern).flatten.map{|e| e.gsub(/\s+/, " ")}.uniq.sort               # Panels are counted directly
    # create a hash with the figures
#    h_figs = {}
#    figures.map{|e| h_figs[e] = 1}
    # Group figures by their base number
    grouped_figures = figures.group_by { |figure| figure[/\d+/] }

    # Remove items with only the number if there are occurrences with letters
    filtered_figures = grouped_figures.flat_map do |_, group|
      if group.any? { |figure| figure.match?(/\d+[A-Z]/) }
        group.reject { |figure| figure.match?(/^\D+\d+$/) }
      else
        group
      end
    end   

    tables = text.scan(table_pattern).flatten.map{|e| e.downcase.gsub(/\s+/, " ")}.uniq.sort          # Unique matches for tables
    
    return doi, filtered_figures, tables
  end
  
  Article.all.select{|a| a.pdf_txt_filename }.each do |a|
    
    puts "Working on #{a.pmid}..."
    
    txt_dir = Pathname.new(APP_CONFIG[:share_data_dir]) + 'repro_pdfs_400_txt'
    txt_pdf_path = txt_dir + a.pdf_txt_filename
    
    begin                                                                                                                                                                                                                                

      puts `ls #{txt_pdf_path.to_s}`

      # Get the counts of figures, panels, and tables                                                                                                                                                                                    
      doi, panels, tables = panels_tables(txt_pdf_path)

      # Output the results

      puts "Panels: #{panels.join(",")}"

#      puts "Panels: #{panels.join(",")}"

      puts "Tables: #{tables.join(",")}"                                                                                                                                                                                             

      a.update_attributes(:nber_panels => panels.size, :nber_tables => tables.size)
    end   
    
  end
  
  
end
