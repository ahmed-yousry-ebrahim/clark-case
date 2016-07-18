class V1::CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy, :toggle_like]
  before_action :set_post
  before_action :set_comment, only: [:show, :update, :destroy, :toggle_like]

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    render partial: 'comment', locals: { comment: @comment }
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.post = @post
    if @comment.save
      render json: (render_to_string(partial: 'comment', locals: { comment: @comment })), status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      render json: (render_to_string(partial: 'comment', locals: { comment: @comment })), status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy

    head :no_content
  end

  # GET /comments/1/toggle_like
  # GET /comments/1/toggle_like.json

  def toggle_like
    if current_user.toggle_like!(@comment)
      render json: {:likers_count => @comment.likers_count}, status: :ok
    else
      render json: {:likers_count => @comment.likers_count}, status: :internal_server_error
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    return params.require(:comment).permit(:text)
  end
end
