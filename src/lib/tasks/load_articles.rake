desc '####################### Load articles'
task load_articles: :environment do
  puts 'Executing...'

  now = Time.now

  f = Pathname.new(APP_CONFIG[:data_dir]) + 'preliminary_annots' + 'Reproducibility PMID List.txt'

  list_pmids = []
  File.open(f, 'r') do |f|
    while (l = f.gets) do
      l.chomp!
      list_pmids.push l	
    end
  end

  puts list_pmids.size

  Fetch.load_articles(list_pmids, Workspace.find(1), User.find(1))

end   
