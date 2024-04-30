class Share < ApplicationRecord

  belongs_to :user, :optional => true
  belongs_to :workspace

end
