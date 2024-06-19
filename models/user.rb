class User < ApplicationRecord
  # Ensure Devise modules are included
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  has_many :posts
  has_many :comments

  enum role: { user: 'user', admin: 'admin' }

  def admin?
    role == 'admin'
  end
end
