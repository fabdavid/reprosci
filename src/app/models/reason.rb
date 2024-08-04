class Reason < ApplicationRecord

  belongs_to :assertion
  belongs_to :rel
  belongs_to :user

end
