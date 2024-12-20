desc '####################### Process stats by author'
task process_stats_by_author: :environment do
  puts 'Executing...'

  now = Time.now

  input_filename = Pathname.new(APP_CONFIG[:data_dir]) + "stats_by_author.tsv"

  data = []
  File.open(input_filename, 'r') do |f|
    header = f.gets
    while (l = f.gets) do
      data.push l.chomp.split("\t")
    end
  end
#   header = ["Name", "Sex", "Type", "Career stage", "articles", "major claims"] + list_groups2

  h_data = {'first' => {}, 'leading' => {}}
  h_sum_by_sex = {'first' => {}, 'leading' => {}}
  data.each do |e|
    k = [e[0], e[1]]
    h_data[e[2]][k] ||= []
     h_sum_by_sex[e[2]][e[1]] ||= []
    (4 .. 11).to_a.each do |i|
      h_data[e[2]][k][i-4] ||= 0
      h_data[e[2]][k][i-4] += e[i].to_i
      h_sum_by_sex[e[2]][e[1]][i-4] ||= 0
      h_sum_by_sex[e[2]][e[1]][i-4] += e[i].to_i
    end
  end
  
  
  list_groups2 = ["Articles", "Major claims", "Unchallenged", "Verified", "Partially verified", "Mixed", "In progress", "Challenged", "% challenged"]
  header = ["Name", "Sex"] + list_groups2
  header2 = ["Sex"] + list_groups2
  #File.open(output_filename, 'w') do |f|
  #  f.write header.join("\n")
  #  h_data.each_key do |k|
  #    t = k + h_data[type][k] + [h_data[type][k].last * 100 / h_data[type][k][1]]
  #    f.write t.join("\t")
  #  end
  #  end
  
  output_filename = Pathname.new(APP_CONFIG[:data_dir]) + 'stats_author.xlsx'
  p = Axlsx::Package.new
  wb = p.workbook
  
  h_data.each_key do |type|
    
    # Add a worksheet
    wb.add_worksheet(name: type.capitalize) do |sheet|
      
      # Add the headers
      sheet.add_row header
      
      # Add data rows (replace this with your actual data)
      authors = h_data[type].keys.sort{|a, b| h_data[type][b][1] <=> h_data[type][a][1]}
      authors.each do |k| 
        sheet.add_row k + h_data[type][k] + [h_data[type][k].last * 100 / h_data[type][k][1]]
      end
    end
    
      # Add a worksheet                                                                                      
    wb.add_worksheet(name: type.capitalize + " by sex") do |sheet|
      
      # Add the headers
      sheet.add_row header2
      
      h_sum_by_sex[type].each_key do |k|
        #        if h_sum_by_sex[type][k]
        #          puts h_sum_by_sex[type][k].to_json
        sheet.add_row [k] + h_sum_by_sex[type][k] + [h_sum_by_sex[type][k].last * 100 / h_sum_by_sex[type][k][1]]
        #       end
      end
      
    end
    
  end
  
  
  # Save the Excel file
  p.serialize(output_filename)
  
  puts "Excel file created at #{output_filename}"

end
