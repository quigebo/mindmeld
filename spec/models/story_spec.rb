require 'rails_helper'

RSpec.describe Story, type: :model do
  let(:user) { create(:user) }
  let(:story) { create(:story, creator: user) }

  describe 'associations' do
    it 'belongs to a creator' do
      expect(story.creator).to eq(user)
    end

    it 'has one story theme' do
      theme = create(:story_theme, story: story)
      expect(story.story_theme).to eq(theme)
    end
  end

  describe 'validations' do
    it 'validates presence of title' do
      story = build(:story, title: nil)
      expect(story).not_to be_valid
      expect(story.errors[:title]).to include("can't be blank")
    end
  end

  describe 'scopes' do
    let!(:themed_story) { create(:story, creator: user, dynamic_theming_enabled: true) }
    let!(:non_themed_story) { create(:story, creator: user, dynamic_theming_enabled: false) }

    describe '.with_dynamic_theming' do
      it 'returns only stories with dynamic theming enabled' do
        expect(Story.with_dynamic_theming).to include(themed_story)
        expect(Story.with_dynamic_theming).not_to include(non_themed_story)
      end
    end

    describe '.without_dynamic_theming' do
      it 'returns only stories with dynamic theming disabled' do
        expect(Story.without_dynamic_theming).to include(non_themed_story)
        expect(Story.without_dynamic_theming).not_to include(themed_story)
      end
    end
  end

  describe 'instance methods' do
    describe '#theming_enabled?' do
      context 'when dynamic_theming_enabled is true' do
        before { story.dynamic_theming_enabled = true }

        it 'returns true' do
          expect(story.theming_enabled?).to be true
        end
      end

      context 'when dynamic_theming_enabled is false' do
        before { story.dynamic_theming_enabled = false }

        it 'returns false' do
          expect(story.theming_enabled?).to be false
        end
      end
    end

    describe '#primary_theme_entity' do
      let!(:entity1) { create(:entity, story: story, name: 'Entity 1', entity_type: 'place') }
      let!(:entity2) { create(:entity, story: story, name: 'Entity 2', entity_type: 'person') }

      it 'returns the most frequently mentioned entity' do
        # Create more mentions for entity2
        create(:comment_entity, entity: entity2, comment: create(:comment, commentable: story), confidence_score: 0.9)
        create(:comment_entity, entity: entity2, comment: create(:comment, commentable: story), confidence_score: 0.8)
        create(:comment_entity, entity: entity1, comment: create(:comment, commentable: story), confidence_score: 0.7)

        expect(story.primary_theme_entity).to eq(entity2)
      end
    end
  end

  describe 'validations' do
    describe 'end_date_after_start_date' do
      context 'when end_date is before start_date' do
        before do
          story.start_date = Date.current
          story.end_date = Date.current - 1.day
        end

        it 'is invalid' do
          expect(story).not_to be_valid
          expect(story.errors[:end_date]).to include('must be after or equal to start date')
        end
      end

      context 'when end_date is after start_date' do
        before do
          story.start_date = Date.current
          story.end_date = Date.current + 1.day
        end

        it 'is valid' do
          expect(story).to be_valid
        end
      end

      context 'when end_date equals start_date' do
        before do
          story.start_date = Date.current
          story.end_date = Date.current
        end

        it 'is valid' do
          expect(story).to be_valid
        end
      end
    end
  end
end
