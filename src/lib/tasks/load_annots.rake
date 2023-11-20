desc '####################### Load annotations'
task load_annots: :environment do
  puts 'Executing...'

  now = Time.now

  annot_dir = Pathname.new(APP_CONFIG[:data_dir]) + 'preliminary_annots'
  
  h_at = {}
  AssertionType.all.each do |at|
    h_at[at.name] = at
  end

  h_articles = {}
  Article.all.each do |a|
    h_articles[a.pmid]=a
  end

  def add_assertion article, at, content, h_at
 
    h_assertion = {
      :assertion_type_id => h_at[at].id,
      :content => content,
      :article_id => article.id,
      :user_id => 1
    }
#puts 'bla'
    assertion = Assertion.where(h_assertion).first
puts assertion 
   if !assertion
      puts("add new assertion")
      assertion = Assertion.new(h_assertion)
      assertion.save
    end
    return assertion
  end
  
  
  Dir.new(annot_dir).entries.select{|e| e.match(/\d+\.txt/)}.each do |filename|
    
    article = nil
    if m = filename.match(/^(\d+)\.txt/) 
      article = h_articles[m[1].to_i]
      if !article
       Fetch.load_articles([m[1].to_i])
      end
    end

  end
  
  h_articles = {}
  Article.all.each do |a|
    h_articles[a.pmid]=a
  end

  Dir.new(annot_dir).entries.select{|e| e.match(/\d+\.txt/)}.each do |filename|

    article = nil
    
    if m = filename.match(/^(\d+)\.txt/)
      article = h_articles[m[1].to_i]
    end
    
    if article
      
      puts "Loading #{filename}..."
      cur_at = nil
      cur_claim = nil
      File.open(annot_dir + filename, 'r') do |f|
        while (l = f.gets) do
          l.force_encoding(Encoding::ISO_8859_1).encode(Encoding::UTF_8).chomp!.strip!
	  puts l
          if l.match(/^Major method/)
            puts "Major method"
            cur_at = 'method'
          elsif m = l.match(/^Main\s*\:\s*(.+)/)
            puts "Main"
            cur_at = 'main_claim'
            cur_claim = add_assertion(article, cur_at, m[1], h_at)
          elsif l.match(/^Major/)
            puts "Major"
            cur_at = 'major_claim'
          elsif l.match(/^Minor/)
            puts "Minor"
            cur_at = 'minor_claim'
          elsif m = l.match(/^\* (.+)/)
            puts "Evidence"
            evidence = add_assertion(article, 'evidence', m[1], h_at)
            ## new rel 
            h_rel = {
              :subject_id => evidence.id,
              :complement_id => cur_claim.id,
              :rel_type_id => 1
            }
	    rel = Rel.where(h_rel).first
	    if !rel 
              rel = Rel.new(h_rel)
              rel.save  
            end
          elsif cur_at != nil and m = l.match(/\d+\. (.+?)$/)
            cur_claim = add_assertion(article, cur_at, m[1], h_at)
          end
          
        end
      end
    end

  end

end
