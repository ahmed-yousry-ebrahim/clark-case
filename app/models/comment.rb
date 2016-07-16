class Comment < ActiveRecord::Base
  acts_as_likeable
  belongs_to :user
  belongs_to :post

  validates_presence_of :text
end
