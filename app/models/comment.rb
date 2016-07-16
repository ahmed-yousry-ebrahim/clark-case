class Comment < ActiveRecord::Base
  acts_as_likeable
  belongs_to :user
  belongs_to :post

  validates_presence_of :text

  def likers_count
    self.likers(User).count
  end
end
