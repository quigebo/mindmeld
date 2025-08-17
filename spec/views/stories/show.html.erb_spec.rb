require 'rails_helper'

RSpec.describe 'stories/show', type: :view do
  let(:user) { create(:user) }
  let(:story) { create(:story, creator: user) }
  let(:entity) { create(:entity, story: story, name: 'Paris', entity_type: 'place') }
  let(:theme_data) do
    {
      primary_entity: entity,
      background_image_url: 'https://example.com/paris.jpg',
      icon_pack: nil,
      metadata: { 'analyzed_at' => Time.current.iso8601 }
    }
  end

  before do
    # Mock Devise authentication
    allow(view).to receive(:user_signed_in?).and_return(false)
    allow(view).to receive(:current_user).and_return(nil)

    # Mock the problematic helper method by defining it on the view
    def view.user_can_comment_on_story?
      false
    end

    assign(:story, story)
    assign(:grouped_entities, Entity.grouped_by_type(story))
    assign(:synthesized_memory, nil)
    assign(:comments, [])
    assign(:theme_data, theme_data)
  end

  context 'when theme data is present' do
    it 'renders the theme background' do
      render

      expect(rendered).to include('background-image: url(\'https://example.com/paris.jpg\')')
      expect(rendered).to include('Themed: Paris')
    end

    it 'applies backdrop blur to content sections' do
      render

      expect(rendered).to include('bg-opacity-95 backdrop-blur-sm')
    end
  end

  context 'when theme data is not present' do
    before do
      assign(:theme_data, nil)
    end

    it 'renders without theme background' do
      render

      expect(rendered).not_to include('background-image: url(')
      expect(rendered).not_to include('Themed:')
    end

    it 'uses standard background colors' do
      render

      expect(rendered).to include('bg-gray-50')
      expect(rendered).to include('bg-white')
    end
  end
end
