class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @posts = Post.where("title LIKE :search OR description LIKE :search OR id IN (?)", search: search_term, ids: Post.joins(:tags).where(tags: { name: params[:search] }).pluck(:id))
                   .distinct
    else
      @posts = if user_signed_in?
                 Post.all
               else
                 Post.where(public: true)
               end
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
    @post = current_user.posts.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    print("metdoa")
    @post = Post.find(params[:id])
    @post.destroy

    redirect_to root_path, status: :see_other
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description, :image, :public)
  end
end

