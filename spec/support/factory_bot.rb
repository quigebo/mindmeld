# FactoryBot configuration
FactoryBot.define do
  # User factory
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User #{n}" }
    password { "password123" }
    password_confirmation { "password123" }
  end

  # Story factory
  factory :story do
    sequence(:title) { |n| "Story #{n}" }
    sequence(:description) { |n| "Description for story #{n}" }
    association :creator, factory: :user
    dynamic_theming_enabled { true }
  end

  # Entity factory
  factory :entity do
    sequence(:name) { |n| "Entity #{n}" }
    entity_type { %w[person place thing].sample }
    association :story, factory: :story
  end

  # StoryTheme factory
  factory :story_theme do
    association :story, factory: :story
    association :source_entity, factory: :entity
    background_image_url { nil }
    icon_pack { nil }
    metadata { {} }
  end

  # Comment factory
  factory :comment do
    sequence(:body) { |n| "Comment #{n}" }
    association :user, factory: :user
    association :commentable, factory: :story
  end

  # CommentEntity factory
  factory :comment_entity do
    association :comment, factory: :comment
    association :entity, factory: :entity
    confidence_score { rand(0.5..1.0).round(2) }
  end

  # Participant factory
  factory :participant do
    association :user, factory: :user
    association :story, factory: :story
    status { "invited" }
  end

  # SynthesizedMemory factory
  factory :synthesized_memory do
    association :story, factory: :story
    sequence(:content) { |n| "Synthesized memory content #{n}" }
    metadata { { title: "Test Memory", summary: "Test summary" } }
    generated_at { Time.current }
  end
end
