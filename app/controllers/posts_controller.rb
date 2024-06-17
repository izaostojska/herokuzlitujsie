class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @posts = Post.where(public: true)
                   .where("title LIKE :search OR description LIKE :search", search: search_term)
                   .or(Post.where(id: Post.joins(:tags).where(tags: { name: params[:search] }).pluck(:id)))
                   .distinct
    else
      @posts = Post.where(public: true).or(Post.where(user: current_user))
    end
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    tag_names = params[:post][:tag_names].split(',')
    tag_names.each do |tag_name|
      tag = Tag.find_or_create_by(name: tag_name.strip)
      @post.tags << tag
    end
    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: 'Post was successfully deleted.'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description, :image, :public)
  end
end
