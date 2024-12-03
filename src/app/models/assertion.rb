class Assertion < ApplicationRecord

  belongs_to :assertion_type
  belongs_to :article
  belongs_to :user
  belongs_to :orcid_user, :optional => true
  belongs_to :assessment_type, :optional => true
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :genes
  has_many :assertion_versions
  
  searchable do
    integer :id
    text :content
    text :authors_txt, :boost => 3 do
      article.authors_txt if article
    end
    text :authors_unaccentuated, :boost => 3 do
      I18n.transliterate article.authors_txt if article
    end
   
    text :tags, :boost => 2 do
      tags.map{|t| t.name}
    end
    text :gene_names, :boost => 2 do
      genes.map{|g| g.name}
    end
    text :gene_ensembl_id, :boost => 2 do
      genes.map{|g| g.ensembl_id}
    end
    text :gene_description do
      genes.map{|g| g.description}
    end
    integer :assertion_type_id, :multiple => true 
    integer :assessment_type_id, :multiple => true do
      assessment_type_id || ''
    end
    integer :workspace_id do
      (article) ? article.workspace_id : nil
    end
    boolean :obsolete
    boolean :obsolete_article do
      (article) ? article.obsolete : true
    end    
    time :updated_at
  end


end
