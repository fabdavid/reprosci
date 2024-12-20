desc '####################### Init reasons'
task init_reasons: :environment do
  puts 'Executing...'

  now = Time.now

  Assertion.all.each do |a|
    
    if [3, 10, 11].include? a.assessment_type_id
      
      #              h_reason_types = {}                                                                                  
      #              ReasonType.all.map{|rt| h_reason_types[rt.id] = }                                                    

      h = {:subject_id => a.id, :rel_type_id => 2}
      puts h.to_json
      rel = Rel.where(h).first ## select assessment
      if rel
        puts rel.id
        h_reason = {
          :reason_type_ids => nil, #params[:reason_type_id],                                                                 
          :assertion_id => a.id,
          :rel_id => rel.id,
          :user_id => 1
        }
        reason = Reason.where(:assertion_id => a, :rel_id => rel.id).first
        if !reason
          reason = Reason.new(h_reason)
          reason.save
        end
      end
    end
  end

end
