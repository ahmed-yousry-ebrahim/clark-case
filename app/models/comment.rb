class Comment < ActiveRecord::Base
  acts_as_likeable
  belongs_to :user
  belongs_to :post, :counter_cache => true

  validates_presence_of :text, :user_id, :post_id

  def likers_count
    self.likers(User).count
  end
end
