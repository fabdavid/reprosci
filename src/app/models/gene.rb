class Gene < ApplicationRecord

   has_and_belongs_to_many :assertions

  searchable do
    text :name, :boost => 2 do
      (name) ? name.gsub(/[^\d\w]/, '_') : ''
    end
    text :ensembl_id, :boost => 2
    integer :organism_id
    text :description do
      (description) ? description.gsub(/[^\d\w]/, '_') : ''
    end
    text :alt_names, :stored => true do
      (alt_names) ? alt_names.gsub(/[^\d\w\,]/, '_').split(",") : []
    end
    time :updated_at
  end

end
