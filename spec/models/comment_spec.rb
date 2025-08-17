require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:story) { create(:story, creator: user) }

  describe 'callbacks' do
    describe '#schedule_theme_analysis' do
      context 'when comment is for a story with theming enabled' do
        before { story.update!(dynamic_theming_enabled: true) }

        it 'enqueues ThemeAnalysisJob' do
          expect {
            create(:comment, commentable: story, user: user)
          }.to have_enqueued_job(Theming::ThemeAnalysisJob).with(story.id)
        end
      end

      context 'when comment is for a story with theming disabled' do
        before { story.update!(dynamic_theming_enabled: false) }

        it 'does not enqueue ThemeAnalysisJob' do
          expect {
            create(:comment, commentable: story, user: user)
          }.not_to have_enqueued_job(Theming::ThemeAnalysisJob)
        end
      end
    end
  end
end
