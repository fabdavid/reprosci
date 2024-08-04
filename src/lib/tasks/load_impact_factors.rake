desc '####################### Load impact factors'
task load_impact_factors: :environment do
  puts 'Executing...'

  now = Time.now

  impact_factor_file = Pathname.new(APP_CONFIG[:data_dir]) + '20240503_repro_impact_factor.txt'

  h_journals = {}
  Journal.all.map{|j| h_journals[j.name] = j}
  
  File.open(impact_factor_file, 'r') do |f|
    while l= f.gets
      t = l.chomp.split(/\t/)
      puts t.to_json
      if h_journals[t[0]]
        h_journals[t[0]].update_attributes({:impact_factor => t[1]})
      end
    end
  end

  
end
