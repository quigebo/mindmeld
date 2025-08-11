require 'rails_helper'

RSpec.describe Story, type: :model do
  describe 'validations' do
    it 'validates presence of title' do
      story = build(:story, title: nil)
      expect(story).not_to be_valid
      expect(story.errors[:title]).to include("can't be blank")
    end

    it 'validates presence of creator' do
      story = build(:story, creator: nil)
      expect(story).not_to be_valid
      expect(story.errors[:creator]).to include('must exist')
    end
  end

  describe 'associations' do
    it 'belongs to a creator' do
      user = create(:user)
      story = create(:story, creator: user)
      expect(story.creator).to eq(user)
    end

    it 'has many participants' do
      story = create(:story)
      participant = create(:participant, story: story)
      expect(story.participants).to include(participant)
    end

    it 'has many comment threads' do
      story = create(:story)
      comment = create(:comment, commentable: story)
      expect(story.comment_threads).to include(comment)
    end

    it 'has one synthesized memory' do
      story = create(:story)
      memory = create(:synthesized_memory, story: story)
      expect(story.synthesized_memory).to eq(memory)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:story)).to be_valid
    end
  end

  describe 'LLM integration' do
    let(:story) { create(:story) }

    describe '#has_pending_analysis?' do
      it 'returns true when there are comments without analysis' do
        create(:comment, commentable: story, is_memory_worthy: nil)
        expect(story.has_pending_analysis?).to be true
      end

      it 'returns false when all comments have been analyzed' do
        create(:comment, commentable: story, is_memory_worthy: true)
        create(:comment, commentable: story, is_memory_worthy: false)
        expect(story.has_pending_analysis?).to be false
      end

      it 'returns false when there are no comments' do
        expect(story.has_pending_analysis?).to be false
      end
    end

    describe '#ready_for_synthesis?' do
      it 'returns true when there are memory-worthy comments' do
        create(:comment, commentable: story, is_memory_worthy: true)
        expect(story.ready_for_synthesis?).to be true
      end

      it 'returns false when there are no memory-worthy comments' do
        create(:comment, commentable: story, is_memory_worthy: false)
        expect(story.ready_for_synthesis?).to be false
      end

      it 'returns false when there are no comments' do
        expect(story.ready_for_synthesis?).to be false
      end
    end

    describe '#latest_synthesized_memory_with_metadata' do
      it 'returns nil when no synthesized memory exists' do
        expect(story.latest_synthesized_memory_with_metadata).to be_nil
      end

      it 'returns metadata when synthesized memory exists' do
        memory = create(:synthesized_memory, story: story)
        result = story.latest_synthesized_memory_with_metadata
        
        expect(result).to include(
          content: memory.content,
          title: memory.metadata['title'],
          summary: memory.metadata['summary'],
          generated_at: memory.generated_at
        )
      end
    end

    describe '#llm_service' do
      it 'raises NotImplementedError' do
        expect { story.llm_service }.to raise_error(NotImplementedError, 'LLM services not yet available')
      end
    end

    describe '#regenerate_synthesis!' do
      it 'raises NotImplementedError' do
        expect { story.regenerate_synthesis! }.to raise_error(NotImplementedError, 'LLM services not yet available')
      end
    end

    describe '#reanalyze_all_comments!' do
      it 'raises NotImplementedError' do
        expect { story.reanalyze_all_comments! }.to raise_error(NotImplementedError, 'LLM services not yet available')
      end
    end
  end
end
