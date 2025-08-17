require 'rails_helper'

RSpec.describe StoryTheme, type: :model do
  let(:story) { create(:story) }
  let(:entity) { create(:entity, story: story) }

  describe 'associations' do
    it 'belongs to a story' do
      story_theme = build(:story_theme, story: story, source_entity: entity)
      expect(story_theme.story).to eq(story)
    end

    it 'belongs to a source entity' do
      story_theme = build(:story_theme, story: story, source_entity: entity)
      expect(story_theme.source_entity).to eq(entity)
    end
  end

  describe 'validations' do
    it 'requires a unique story' do
      create(:story_theme, story: story, source_entity: entity)
      duplicate_theme = build(:story_theme, story: story, source_entity: create(:entity, story: story))
      expect(duplicate_theme).not_to be_valid
      expect(duplicate_theme.errors[:story]).to include('has already been taken')
    end

    it 'requires a source entity' do
      story_theme = build(:story_theme, story: story, source_entity: nil)
      expect(story_theme).not_to be_valid
      expect(story_theme.errors[:source_entity]).to include("must exist")
    end
  end

  describe 'scopes' do
    let!(:theme_with_image) { create(:story_theme, story: story, source_entity: entity, background_image_url: 'https://example.com/image.jpg') }
    let!(:theme_without_image) { create(:story_theme, story: create(:story), source_entity: create(:entity), background_image_url: nil) }

    describe '.with_background_images' do
      it 'returns only themes with background images' do
        expect(StoryTheme.with_background_images).to include(theme_with_image)
        expect(StoryTheme.with_background_images).not_to include(theme_without_image)
      end
    end
  end

  describe 'instance methods' do
    let(:story_theme) { create(:story_theme, story: story, source_entity: entity) }

    describe '#has_background_image?' do
      context 'when background_image_url is present' do
        before { story_theme.background_image_url = 'https://example.com/image.jpg' }

        it 'returns true' do
          expect(story_theme.has_background_image?).to be true
        end
      end

      context 'when background_image_url is blank' do
        before { story_theme.background_image_url = nil }

        it 'returns false' do
          expect(story_theme.has_background_image?).to be false
        end
      end
    end

    describe '#has_icon_pack?' do
      context 'when icon_pack is present' do
        before { story_theme.icon_pack = 'nature' }

        it 'returns true' do
          expect(story_theme.has_icon_pack?).to be true
        end
      end

      context 'when icon_pack is blank' do
        before { story_theme.icon_pack = nil }

        it 'returns false' do
          expect(story_theme.has_icon_pack?).to be false
        end
      end
    end

    describe '#metadata_value' do
      before { story_theme.metadata = { 'api_response' => 'test_data' } }

      it 'returns the value for the given key' do
        expect(story_theme.metadata_value('api_response')).to eq('test_data')
      end

      it 'returns nil for non-existent key' do
        expect(story_theme.metadata_value('non_existent')).to be_nil
      end
    end

    describe '#set_metadata_value' do
      it 'sets a value in metadata' do
        story_theme.set_metadata_value('test_key', 'test_value')
        expect(story_theme.metadata['test_key']).to eq('test_value')
      end

      it 'initializes metadata if nil' do
        story_theme.metadata = nil
        story_theme.set_metadata_value('test_key', 'test_value')
        expect(story_theme.metadata).to eq({ 'test_key' => 'test_value' })
      end
    end
  end
end
