class Post < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :comments, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true, length: { minimum: 5 }
  validates :description, presence: true, length: { minimum: 10 }
  validate :tags_count_within_range
  validate :image_format

  def tags_count_within_range
    tags_array = tags.split(',')
    if tags_array.size < 1 || tags_array.size > 10
      errors.add(:tags, "must have between 1 and 10 tags")
    end
  end

  def tag_names
    tags.pluck(:name)
  end

  def image_format
    return unless image.attached?

    if !image.blob.content_type.starts_with?('image/')
      errors.add(:image, 'must be an image')
    end
  end
end
