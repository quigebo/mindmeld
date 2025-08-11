class Comment < ActiveRecord::Base
  # acts_as_commentable_with_threading sets up the nested set structure
  acts_as_nested_set scope: [:commentable_id, :commentable_type]

  # Associations
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  # Validations
  validates :body, presence: true
  validates :user, presence: true

  # Scopes
  scope :memory_worthy, -> { where(is_memory_worthy: true) }
  scope :chronological, -> { order(:occurred_at, :created_at) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_save :clean_content
  after_create :schedule_analysis

  # Helper methods to build comments
  def self.build_from(obj, user_id, body, subject = nil, parent_id = nil)
    new(
      commentable: obj,
      user_id: user_id,
      body: body,
      subject: subject,
      parent_id: parent_id
    )
  end

  # Check if this comment has children
  def has_children?
    children.any?
  end

  # Custom methods for our LLM integration
  def mark_as_memory_worthy!(analysis = {})
    update!(
      is_memory_worthy: true,
      llm_analysis: analysis
    )
  end

  def mark_as_not_memory_worthy!(reason = nil)
    update!(
      is_memory_worthy: false,
      llm_analysis: { reason: reason }
    )
  end

  private

  def clean_content
    self.body = body&.strip
  end

  def schedule_analysis
    CommentAnalysisJob.perform_later(id)
  end
end
