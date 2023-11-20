desc '####################### Fix assessment_type'
task fix_assessment_type: :environment do
  puts 'Executing...'

  now = Time.now

  Assertion.all.each do |assertion| 
    assertion_type = assertion.assertion_type
    if assertion_type.name == 'assessment'
      rel = Rel.joins(:rel_type).where(:subject_id => assertion.id, :rel_types => {:name => 'assessment'}).first
      complement = Assertion.where(:id => rel.complement_id).first
      puts "update #{complement.id} assessment_type_id: #{complement.assessment_type_id} => #{assertion.assessment_type_id}" 
       complement.update_attributes(:assessment_type_id => assertion.assessment_type_id)
    end
  end
  

end
