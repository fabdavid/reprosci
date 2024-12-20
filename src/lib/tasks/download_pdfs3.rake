desc "Download PDFs for a list of PubMed IDs"
task download_pdfs3: :environment do

  output_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'pdfs' + 'tmp'
  
  pmid_list = Article.all.map{|a| a.pmid}
  pmid_list.each do |pmid|
    begin
      filename = Pathname.new(APP_CONFIG[:data_dir]) + 'pdfs' + "#{pmid}.pdf"
      json_filename =  Pathname.new(APP_CONFIG[:data_dir]) + 'pdfs' + "#{pmid}.json"
      FileUtils.rm_r output_dir if File.exist? output_dir
      Dir.mkdir output_dir #if !File.exist? output_dir
      
      if !File.exist? filename
        command = "pygetpapers -q #{pmid} --pdf -o #{output_dir}"
        puts "Running: #{command}"
        system(command)
        cmd = "find #{output_dir} -name fulltext.pdf"
        pdf_path = `#{cmd}`.chomp
        puts cmd
        cmd = "find #{output_dir} -name eupmc_result.json"
        json_path = `#{cmd}`.chomp
        puts cmd

        puts "t1"
        if !json_path.empty? #and File.exist? json_path
          puts "copy #{json_path} => #{json_filename.to_s}"
          FileUtils.copy json_path, json_filename.to_s
        end
        puts "t2"
        if pdf_path.empty? #and !File.exist? pdf_path
          puts "Failed to download PDF for PubMed ID: #{pmid}"
        else
          FileUtils.copy pdf_path, filename.to_s
          puts "Downloaded PDF for PubMed ID: #{pmid}"
        end
        
#        FileUtils.rm_r output_dir
      end
    rescue => e
        puts "An error occurred for PubMed ID #{pmid}: #{e.message}"
    end
    
  end
  
end
