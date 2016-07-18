# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

admin_user = User.find_or_initialize_by(email: 'admin@clark-case.com')
admin_user.password = '12345678'
admin_user.is_admin = true
admin_user.save!

seed_post = Post.find_or_initialize_by(body: 'sample seed post')
seed_post.user = admin_user
seed_post.save!

seed_comment = Comment.find_or_initialize_by(text: 'sample seed comment')
seed_comment.post = seed_post
seed_comment.user = admin_user
seed_comment.save!