# Temporary workaround for autoloading issue
load 'app/models/concerns/llm_integration.rb' unless defined?(LLMIntegration)

class Story < ApplicationRecord
  # Enable threaded comments
  acts_as_commentable

  # Include LLM integration
  include LLMIntegration

  # Associations
  belongs_to :creator, class_name: 'User'
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  has_one :synthesized_memory, dependent: :destroy

  # Validations
  validates :title, presence: true
  validate :end_date_after_start_date

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?

    if end_date < start_date
      errors.add(:end_date, "must be after or equal to start date")
    end
  end
end
