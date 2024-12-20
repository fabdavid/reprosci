class Author < ApplicationRecord

  belongs_to :article, :optional => true
  belongs_to :career_stage, :optional => true
  belongs_to :expertise_level, :optional => true
  
end
