class Article < ApplicationRecord

#  has_and_belongs_to_many :genes
  has_many :claims
  has_many :assertions
  has_many :authors
  belongs_to :journal
  belongs_to :workspace
  belongs_to :user

  searchable do
    integer :id
    text :authors_txt, :boost => 3
    text :authors_unaccentuated, :boost => 3 do
      I18n.transliterate authors_txt
    end
    text :title,  :boost => 3
    text :abstract, :boost => 2
    integer :pmid
    integer :nber_claims do
      assertions.select{|a| a.obsolete == false and [1, 2, 3].include?(a.assertion_type_id)}.size
    end
    text :journal_name do
      journal.name
    end
    text :claims do
      assertions.select{|a| a.obsolete == false and [1, 2, 3].include?(a.assertion_type_id)}.map{|a| a.content}
    end
    time :updated_at
  end
end
