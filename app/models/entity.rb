class Entity < ApplicationRecord
  # Associations
  belongs_to :story
  has_many :comment_entities, dependent: :destroy
  has_many :comments, through: :comment_entities

  # Validations
  validates :name, presence: true
  validates :entity_type, presence: true, inclusion: { in: %w[person place thing] }
  validates :name, uniqueness: { scope: [:story_id, :entity_type] }

  # Scopes
  scope :people, -> { where(entity_type: 'person') }
  scope :places, -> { where(entity_type: 'place') }
  scope :things, -> { where(entity_type: 'thing') }
  scope :by_mention_count, -> { 
    left_joins(:comment_entities)
      .group(:id)
      .order('COUNT(comment_entities.id) DESC')
  }

  # Instance methods
  def mention_count
    comment_entities.size
  end

  def average_confidence
    comment_entities.average(:confidence_score)&.round(2)
  end

  def first_mentioned_at
    comment_entities.joins(:comment).minimum('comments.created_at')
  end

  def last_mentioned_at
    comment_entities.joins(:comment).maximum('comments.created_at')
  end

  def mentioned_comments
    comments.order(:created_at)
  end

  # Class methods
  def self.find_or_create_for_story(story, name, entity_type, confidence_score = nil)
    entity = find_or_create_by(
      story: story,
      name: name.strip,
      entity_type: entity_type
    )

    # If we have a confidence score, create/update the comment entity association
    if confidence_score
      entity.comment_entities.find_or_create_by(
        comment: story.comment_threads.last,
        confidence_score: confidence_score
      )
    end

    entity
  end

  def self.grouped_by_type(story)
    {
      people: story.entities.people.by_mention_count,
      places: story.entities.places.by_mention_count,
      things: story.entities.things.by_mention_count
    }
  end
end
