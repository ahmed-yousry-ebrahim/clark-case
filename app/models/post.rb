class Post < ActiveRecord::Base
  acts_as_likeable
  belongs_to :user
  has_many :comments, :dependent => :delete_all

  validates_presence_of :body, :user_id

  def likers_count
    self.likers(User).count
  end
end
