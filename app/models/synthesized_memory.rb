class SynthesizedMemory < ApplicationRecord
  # Enable versioning with Paper Trail
  has_paper_trail

  # Associations
  belongs_to :story

  # Validations
  validates :content, presence: true

  # Callbacks
  before_validation :set_defaults, on: :create

  # Scopes
  scope :latest, -> { order(created_at: :desc).first }

  # Instance methods
  def included_comment_ids
    metadata&.dig('included_comment_ids') || []
  end

  def included_comment_ids=(ids)
    self.metadata ||= {}
    self.metadata['included_comment_ids'] = ids
  end

  def generation_details
    metadata&.dig('generation_details') || {}
  end

  def generation_details=(details)
    self.metadata ||= {}
    self.metadata['generation_details'] = details
  end

  private

  def set_defaults
    self.generated_at ||= Time.current
    self.metadata ||= {}
  end
end
