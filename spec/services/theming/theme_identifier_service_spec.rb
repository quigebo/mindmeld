require 'rails_helper'

RSpec.describe Theming::ThemeIdentifierService, type: :service do
  let(:user) { create(:user) }
  let(:story) { create(:story, creator: user) }
  let(:service) { described_class.new(story) }

  describe '#identify_primary_theme' do
    context 'when story has no entities' do
      it 'returns nil' do
        expect(service.identify_primary_theme).to be_nil
      end
    end

    context 'when story has entities' do
      let!(:place_entity) { create(:entity, story: story, name: 'Paris', entity_type: 'place') }
      let!(:person_entity) { create(:entity, story: story, name: 'John', entity_type: 'person') }
      let!(:thing_entity) { create(:entity, story: story, name: 'Eiffel Tower', entity_type: 'thing') }

      before do
        # Create comment entities to give them mention counts
        create(:comment_entity, entity: place_entity, comment: create(:comment, commentable: story), confidence_score: 0.9)
        create(:comment_entity, entity: place_entity, comment: create(:comment, commentable: story), confidence_score: 0.8)
        create(:comment_entity, entity: person_entity, comment: create(:comment, commentable: story), confidence_score: 0.7)
        create(:comment_entity, entity: thing_entity, comment: create(:comment, commentable: story), confidence_score: 0.95)
      end

      it 'prefers theme-worthy entity types (place, thing) over person' do
        primary_theme = service.identify_primary_theme
        expect(primary_theme).to be_in([place_entity, thing_entity])
        expect(primary_theme).not_to eq(person_entity)
      end

      it 'returns the entity with the highest score' do
        # Give thing_entity more mentions to make it the highest scorer
        create(:comment_entity, entity: thing_entity, comment: create(:comment, commentable: story), confidence_score: 0.9)
        create(:comment_entity, entity: thing_entity, comment: create(:comment, commentable: story), confidence_score: 0.9)

        expect(service.identify_primary_theme).to eq(thing_entity)
      end
    end

    context 'when story has theming disabled' do
      before { story.update!(dynamic_theming_enabled: false) }

      it 'returns nil' do
        expect(service.identify_primary_theme).to be_nil
      end
    end
  end

  describe '#identify_secondary_themes' do
    let!(:place_entity) { create(:entity, story: story, name: 'Paris', entity_type: 'place') }
    let!(:person_entity) { create(:entity, story: story, name: 'John', entity_type: 'person') }
    let!(:thing_entity) { create(:entity, story: story, name: 'Eiffel Tower', entity_type: 'thing') }

    before do
      create(:comment_entity, entity: place_entity, comment: create(:comment, commentable: story), confidence_score: 0.9)
      create(:comment_entity, entity: person_entity, comment: create(:comment, commentable: story), confidence_score: 0.7)
      create(:comment_entity, entity: thing_entity, comment: create(:comment, commentable: story), confidence_score: 0.8)
    end

    it 'returns secondary entities excluding the primary theme' do
      secondary_themes = service.identify_secondary_themes
      primary_theme = service.identify_primary_theme

      expect(secondary_themes).not_to include(primary_theme)
      expect(secondary_themes.length).to be <= 3
    end

    it 'respects the limit parameter' do
      secondary_themes = service.identify_secondary_themes(2)
      expect(secondary_themes.length).to be <= 2
    end
  end

  describe 'entity scoring' do
    let!(:entity) { create(:entity, story: story, name: 'Paris', entity_type: 'place') }

    before do
      create(:comment_entity, entity: entity, comment: create(:comment, commentable: story), confidence_score: 0.9)
    end

    it 'gives bonus points to theme-worthy entity types' do
      # The scoring logic should favor 'place' entities over 'person' entities
      place_entity = create(:entity, story: story, name: 'London', entity_type: 'place')
      person_entity = create(:entity, story: story, name: 'Jane', entity_type: 'person')

      create(:comment_entity, entity: place_entity, comment: create(:comment, commentable: story), confidence_score: 0.9)
      create(:comment_entity, entity: person_entity, comment: create(:comment, commentable: story), confidence_score: 0.9)

      primary_theme = service.identify_primary_theme
      expect(primary_theme.entity_type).to eq('place')
    end

    it 'penalizes generic entity names' do
      generic_entity = create(:entity, story: story, name: 'some place', entity_type: 'place')
      specific_entity = create(:entity, story: story, name: 'Eiffel Tower', entity_type: 'place')

      create(:comment_entity, entity: generic_entity, comment: create(:comment, commentable: story), confidence_score: 0.9)
      create(:comment_entity, entity: specific_entity, comment: create(:comment, commentable: story), confidence_score: 0.9)

      primary_theme = service.identify_primary_theme
      expect(primary_theme.name).to eq('Eiffel Tower')
    end
  end
end
