json.(post, :id, :body, :likers_count)
json.comments post.comments do |comment|
  json.partial! 'comments/comment' , locals: { comment: comment }
end