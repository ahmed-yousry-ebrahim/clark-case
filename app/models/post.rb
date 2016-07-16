class Post < ActiveRecord::Base
  acts_as_likeable
  belongs_to :user
  has_many :comments

  validates_presence_of :body
end
