class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def download
    @post = Post.find(params[:id])
    respond_to do |format|
      format.pdf do
        render pdf: "download"   # Excluding ".pdf" extension.
      end
    end
  end

  def index
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      if user_signed_in?
        @posts = Post.where("title LIKE :search OR description LIKE :search OR id IN (:ids)", search: search_term, ids: Post.joins(:tags).where(tags: { name: params[:search] }).pluck(:id))
                     .distinct
      else
        @posts = Post.where(public: true).where("title LIKE :search OR description LIKE :search OR id IN (:ids)", search: search_term, ids: Post.joins(:tags).where(tags: { name: params[:search] }).pluck(:id))
                     .distinct
      end
    else
      @posts = if user_signed_in?
                 Post.all
               else
                 Post.where(public: true)
               end
    end
    log_to_both("Wyświetlono listę postów. Szukano: #{params[:search]}, użytkownik zalogowany: #{user_signed_in?}")
  end

  def show
    @post = Post.find(params[:id])
    log_to_both("Wyświetlono szczegóły posta o ID: #{params[:id]}")
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
      log_to_both("Utworzono nowy post o ID: #{@post.id}")
      redirect_to @post, notice: 'Post was successfully created.'
    else
      log_to_both("Błąd podczas tworzenia nowego posta przez użytkownika #{current_user.email}")
      render :new
    end
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      # Aktualizacja tagów na podstawie przekazanych tagów
      tag_names = params[:post][:tag_names].split(',').map(&:strip)
      @post.tags = tag_names.map { |name| Tag.find_or_create_by(name: name) }
      log_to_both("Zaktualizowano post o ID: #{params[:id]} przez użytkownika #{current_user.email}")
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      log_to_both("Błąd podczas aktualizacji posta o ID: #{params[:id]} przez użytkownika #{current_user.email}")
      render :edit
    end
  end

  def destroy
    print("metdoa")
    @post = Post.find(params[:id])
    @post.destroy
    log_to_both("Usunięto post o ID: #{params[:id]} przez użytkownika #{current_user.email}")
    redirect_to root_path, status: :see_other
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :description, :image, :public)
  end

  def log_to_both(message)
    puts message  # Logowanie do konsoli
    Rails.logger.info(message)  # Logowanie do pliku log/development.log lub log/production.log
  end
end
