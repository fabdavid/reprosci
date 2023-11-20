class BannedOrcidUser < ApplicationRecord

  belongs_to :orcid_user
  belongs_to :workspace

end
