class OrcidUser < ApplicationRecord

#  belongs_to :user
  has_many :banned_orcid_users
  has_many :users

end
