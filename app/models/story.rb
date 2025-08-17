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
  has_many :entities, dependent: :destroy
  has_one :story_theme, dependent: :destroy

  # Validations
  validates :title, presence: true
  validate :end_date_after_start_date

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :with_dynamic_theming, -> { where(dynamic_theming_enabled: true) }
  scope :without_dynamic_theming, -> { where(dynamic_theming_enabled: false) }

  # Instance methods
  def theming_enabled?
    dynamic_theming_enabled?
  end

  def primary_theme_entity
    # For now, return the most frequently mentioned entity
    # This will be enhanced in Phase 2 with the ThemeIdentifierService
    entities.by_mention_count.first
  end

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?

    if end_date < start_date
      errors.add(:end_date, "must be after or equal to start date")
    end
  end
end
