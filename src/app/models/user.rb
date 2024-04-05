class User < ApplicationRecord

#  has_one :orcid_user
  belongs_to :orcid_user, :optional => true
  has_many :articles
  has_many :assertions
  has_many :assertion_versions
  has_many :rels
  has_many :shares
  has_many :abuse_reports
  

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  
  #  validates :username, uniqueness: true

  before_destroy :remove_foreign_keys

  def remove_foreign_keys

#    self.assertions.select{|a| a.assertion_type_id == 7}.update_all({:user_id => nil, :obsolete => true})
    self.assertions.update_all({:user_id => nil}) ## not set as obsolete on purpose so that they are still accessible by users
    self.assertion_versions.update_all({:user_id => nil})    
    self.rels.update_all({:user_id => nil}) ## not set as obsolete on purpose so that they are still accessible by users
    self.articles.update_all({:user_id => nil})
    self.abuse_reports.update_all({:user_id => nil})
    self.shares.destroy_all
    
  end

end
