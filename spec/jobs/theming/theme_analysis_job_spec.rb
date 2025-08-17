require 'rails_helper'

RSpec.describe Theming::ThemeAnalysisJob, type: :job do
  let(:user) { create(:user) }
  let(:story) { create(:story, creator: user, dynamic_theming_enabled: true) }
  let(:entity) { create(:entity, story: story, name: 'Paris', entity_type: 'place') }

  before do
    # Create a comment entity to trigger theming
    comment = create(:comment, commentable: story)
    create(:comment_entity, entity: entity, comment: comment, confidence_score: 0.9)
  end

  describe '#perform' do
    context 'when story has theming enabled' do
      it 'executes without error' do
        expect { described_class.perform_now(story.id) }.not_to raise_error
      end

      it 'creates or updates theme data' do
        expect { described_class.perform_now(story.id) }.to change { story.reload.story_theme.present? }.from(false).to(true)
      end

      it 'does not broadcast in test environment' do
        allow(Turbo::StreamsChannel).to receive(:broadcast_update_to)

        described_class.perform_now(story.id)

        expect(Turbo::StreamsChannel).not_to have_received(:broadcast_update_to)
      end
    end

    context 'when story has theming disabled' do
      before do
        story.update!(dynamic_theming_enabled: false)
      end

      it 'executes without error' do
        expect { described_class.perform_now(story.id) }.not_to raise_error
      end

      it 'does not create theme data' do
        expect { described_class.perform_now(story.id) }.not_to change { story.reload.story_theme.present? }
      end
    end

    context 'when story does not exist' do
      it 'logs an error and does not raise' do
        expect { described_class.perform_now(99999) }.not_to raise_error
      end
    end
  end

  describe '#should_broadcast?' do
    it 'returns false in test environment' do
      job = described_class.new
      expect(job.send(:should_broadcast?)).to be false
    end

    it 'would return true in development environment' do
      # Temporarily change the environment to test the logic
      allow(Rails.env).to receive(:test?).and_return(false)

      job = described_class.new
      expect(job.send(:should_broadcast?)).to be true
    end
  end
end
