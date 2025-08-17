class StoryTheme < ApplicationRecord
  # Associations
  belongs_to :story
  belongs_to :source_entity, class_name: 'Entity'

  # Validations
  validates :story, uniqueness: true
  validates :source_entity, presence: true

  # Scopes
  scope :with_background_images, -> { where.not(background_image_url: [nil, '']) }

  # Instance methods
  def has_background_image?
    background_image_url.present?
  end

  def has_icon_pack?
    icon_pack.present?
  end

  def metadata_value(key)
    metadata&.dig(key.to_s)
  end

  def set_metadata_value(key, value)
    self.metadata ||= {}
    self.metadata[key.to_s] = value
  end
end
