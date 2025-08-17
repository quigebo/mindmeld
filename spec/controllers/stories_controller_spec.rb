require 'rails_helper'

RSpec.describe StoriesController, type: :controller do
  let(:user) { create(:user) }
  let(:story) { create(:story, creator: user) }

  describe 'GET #index' do
    context 'when user is signed in' do
      before do
        sign_in user
      end

      it 'shows stories the user created' do
        created_story = create(:story, creator: user, title: 'My Created Story')

        get :index

        expect(assigns(:stories)).to include(created_story)
      end

      it 'shows stories the user participates in' do
        other_user = create(:user)
        participated_story = create(:story, creator: other_user, title: 'Story I Participate In')
        create(:participant, story: participated_story, user: user, status: 'accepted')

        get :index

        expect(assigns(:stories)).to include(participated_story)
      end

      it 'does not show stories the user does not participate in' do
        other_user = create(:user)
        other_story = create(:story, creator: other_user, title: 'Story I Do Not Participate In')

        get :index

        expect(assigns(:stories)).not_to include(other_story)
      end

      it 'orders stories by created_at descending' do
        old_story = create(:story, creator: user, title: 'Old Story', created_at: 2.days.ago)
        new_story = create(:story, creator: user, title: 'New Story', created_at: 1.day.ago)

        get :index

        expect(assigns(:stories).first).to eq(new_story)
        expect(assigns(:stories).second).to eq(old_story)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #show' do
    context 'when story has theming enabled' do
      before do
        story.update!(dynamic_theming_enabled: true)
        # Create an entity to trigger theming
        entity = create(:entity, story: story, name: 'Paris', entity_type: 'place')
        create(:comment_entity, entity: entity, comment: create(:comment, commentable: story), confidence_score: 0.9)
      end

      it 'includes theme data in the view' do
        # Trigger theme analysis first
        theme_service = Theming::ThemeManagementService.new(story)
        theme_service.analyze_and_update_theme

        # Now check the theme data
        theme_data = theme_service.current_theme_data

        expect(theme_data).to be_present
        expect(theme_data[:primary_entity]).to be_present
        expect(theme_data[:background_image_url]).to be_present
      end
    end

    context 'when story has theming disabled' do
      before do
        story.update!(dynamic_theming_enabled: false)
      end

      it 'does not include theme data' do
        theme_service = Theming::ThemeManagementService.new(story)
        theme_data = theme_service.current_theme_data

        expect(theme_data).to be_nil
      end
    end

    context 'when story has no entities' do
      before do
        story.update!(dynamic_theming_enabled: true)
      end

      it 'does not include theme data' do
        theme_service = Theming::ThemeManagementService.new(story)
        theme_data = theme_service.current_theme_data

        expect(theme_data).to be_nil
      end
    end
  end
end
