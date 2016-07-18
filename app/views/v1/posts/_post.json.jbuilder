json.(post, :id, :body, :likers_count, :comments_count)
json.comments post.comments do |comment|
  json.partial! 'comments/comment' , locals: { comment: comment }
end