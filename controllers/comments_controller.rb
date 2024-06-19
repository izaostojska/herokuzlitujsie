class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      log_to_both("Komentarz został pomyślnie utworzony przez użytkownika #{current_user.email}.")
      redirect_to @post, notice: 'Comment was successfully created.'
    else
      log_to_both("Nie udało się utworzyć komentarza przez użytkownika #{current_user.email}.")
      redirect_to @post, alert: 'Failed to create comment.'
    end
  end

  def destroy

  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def log_to_both(message)
    puts message  # Logowanie do konsoli
    Rails.logger.info(message)  # Logowanie do pliku log/development.log lub log/production.log
  end
end
