class Participant < ApplicationRecord
  # Constants
  STATUSES = %w[invited accepted declined].freeze

  # Associations
  belongs_to :user
  belongs_to :story

  # Validations
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :user_id, uniqueness: { scope: :story_id }

  # Scopes
  scope :accepted, -> { where(status: 'accepted') }
  scope :invited, -> { where(status: 'invited') }
  scope :declined, -> { where(status: 'declined') }

  # Callbacks
  before_validation :set_defaults, on: :create

  # Instance methods
  def accept!
    update!(status: 'accepted', joined_at: Time.current)
  end

  def decline!
    update!(status: 'declined')
  end

  def can_contribute?
    accepted?
  end

  def accepted?
    status == 'accepted'
  end

  private

  def set_defaults
    self.status ||= 'invited'
    self.invited_at ||= Time.current
  end
end
