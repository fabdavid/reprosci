desc '####################### Load techniques'
task load_techniques: :environment do
  puts 'Executing...'

  now = Time.now

  data_dir = Pathname.new(APP_CONFIG[:data_dir])
  file = data_dir + 'techniques.txt' 

  File.open(file, 'r') do |f|
    while (l = f.gets) do
      l.chomp!
      h_technique = {
        :label => l 
      }
      technique = Technique.where(h_technique).first
      if !technique
        technique = Technique.new(h_technique)
        technique.save
      end
    end
  end		  

end
