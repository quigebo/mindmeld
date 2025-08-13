class CommentEntity < ApplicationRecord
  # Associations
  belongs_to :comment
  belongs_to :entity

  # Validations
  validates :confidence_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :entity_id, uniqueness: { scope: :comment_id }

  # Scopes
  scope :high_confidence, -> { where('confidence_score >= ?', Llm::EntityExtractionService::MIN_CONFIDENCE_THRESHOLD) }
  scope :by_confidence, -> { order(confidence_score: :desc) }
end
