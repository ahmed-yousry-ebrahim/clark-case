class V1::PostsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  before_action :set_post, only: [:show, :update, :destroy, :toggle_like]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    render partial: 'post', locals: { post: @post }
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      render json: (render_to_string(partial: 'post', locals: { post: @post })), status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    if @post.update(post_params)
      render json: (render_to_string(partial: 'post', locals: { post: @post })), status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy

    head :no_content
  end

  # GET /posts/1/toggle_like
  # GET /posts/1/toggle_like.json
  def toggle_like
    if current_user.toggle_like!(@post)
      render json: {:likers_count => @post.likers_count}, status: :ok
    else
      render json: {:likers_count => @post.likers_count}, status: :internal_server_error
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
      return params.require(:post).permit(:body)
  end
end
