# FactoryBot configuration
FactoryBot.define do
  # User factory
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User #{n}" }
  end

  # Story factory
  factory :story do
    sequence(:title) { |n| "Story #{n}" }
    sequence(:description) { |n| "Description for story #{n}" }
    association :creator, factory: :user
  end

  # Participant factory
  factory :participant do
    association :user, factory: :user
    association :story, factory: :story
    status { "invited" }
  end

  # Comment factory
  factory :comment do
    sequence(:body) { |n| "Comment #{n}" }
    association :user, factory: :user
    association :commentable, factory: :story
  end

  # SynthesizedMemory factory
  factory :synthesized_memory do
    association :story, factory: :story
    sequence(:content) { |n| "Synthesized memory content #{n}" }
    metadata { { title: "Test Memory", summary: "Test summary" } }
    generated_at { Time.current }
  end
end
