class V1::PostsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy, :toggle_like]
  before_action :set_post, only: [:show, :update, :destroy, :toggle_like]
  load_and_authorize_resource

  # GET /posts
  # GET /posts.json
  api :GET, '/v1/posts', 'List posts'
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  api :GET, '/v1/posts/:id', 'Show post'
  param :id, :number, :required => true
  def show
    render partial: 'post', locals: { post: @post }
  end

  # POST /posts
  # POST /posts.json
  api :POST, '/v1/posts', 'Create post'
  param :body, String, :required => true
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
  api :PUT, '/v1/posts/:id', 'Update a post'
  param :id, :number, :required => true
  param :body, String, :required => true
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
  api :DELETE, '/v1/posts/:id', 'Delete a post'
  param :id, :number, :required => true
  def destroy
    @post.destroy

    head :no_content
  end

  # GET /posts/1/toggle_like
  # GET /posts/1/toggle_like.json
  api :GET, '/v1/posts/:id/toggle_like', 'Like / Unlike a post'
  param :id, :number, :required => true
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
