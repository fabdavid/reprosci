class Workspace < ApplicationRecord

  has_many :articles
  has_many :shares
  has_many :banned_orcid_users


  searchable do
    integer :id
    text :name
    integer :nber_annot_articles, :stored => true do
      articles.select{|a| a.assertions.map{|as| [1, 2, 3].include?(as.assertion_type_id) and as.obsolete == false}.size > 0}.size
    end
    time :updated_at
  end

end
