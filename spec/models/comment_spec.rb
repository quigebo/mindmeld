require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    it 'validates presence of body' do
      comment = build(:comment, body: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include("can't be blank")
    end

    it 'validates presence of user' do
      comment = build(:comment, user: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:user]).to include('must exist')
    end

    it 'validates presence of commentable' do
      comment = build(:comment, commentable: nil)
      expect(comment).not_to be_valid
      expect(comment.errors[:commentable]).to include('must exist')
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      comment = create(:comment, user: user)
      expect(comment.user).to eq(user)
    end

    it 'belongs to a commentable' do
      story = create(:story)
      comment = create(:comment, commentable: story)
      expect(comment.commentable).to eq(story)
    end

    it 'has threaded comments' do
      parent_comment = create(:comment)
      child_comment = create(:comment, commentable: parent_comment.commentable, parent: parent_comment)
      expect(parent_comment.children).to include(child_comment)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:comment)).to be_valid
    end
  end

  describe 'callbacks' do
    it 'cleans content before save' do
      comment = build(:comment, body: '  dirty content  ')
      comment.save!
      expect(comment.body).to eq('dirty content')
    end

    it 'schedules analysis after create' do
      expect(CommentAnalysisJob).to receive(:perform_later)
      create(:comment)
    end
  end

  describe 'scopes' do
    let(:story) { create(:story) }

    it 'filters memory-worthy comments' do
      memory_comment = create(:comment, commentable: story, is_memory_worthy: true)
      non_memory_comment = create(:comment, commentable: story, is_memory_worthy: false)
      
      # Test the scope directly on Comment model
      expect(Comment.memory_worthy).to include(memory_comment)
      expect(Comment.memory_worthy).not_to include(non_memory_comment)
    end

    it 'orders comments chronologically' do
      first_comment = create(:comment, commentable: story, created_at: 1.day.ago)
      second_comment = create(:comment, commentable: story, created_at: Time.current)
      
      # Test the scope on comments for this specific story
      story_comments = Comment.where(commentable: story).chronological.to_a
      expect(story_comments).to eq([first_comment, second_comment])
    end
  end

  describe 'LLM analysis' do
    it 'can store LLM analysis data' do
      comment = create(:comment)
      analysis_data = {
        is_memory_worthy: true,
        reasoning: 'This is a significant memory',
        memory_type: 'event',
        confidence: 0.9,
        key_details: ['important detail'],
        analyzed_at: Time.current
      }
      
      comment.update!(llm_analysis: analysis_data)
      # JSON columns are stored as strings, so we need to compare the parsed data
      expect(comment.llm_analysis).to include(
        'is_memory_worthy' => true,
        'reasoning' => 'This is a significant memory',
        'memory_type' => 'event',
        'confidence' => 0.9,
        'key_details' => ['important detail']
      )
    end

    it 'can determine if comment is memory worthy' do
      memory_comment = create(:comment, is_memory_worthy: true)
      non_memory_comment = create(:comment, is_memory_worthy: false)
      
      expect(memory_comment.is_memory_worthy?).to be true
      expect(non_memory_comment.is_memory_worthy?).to be false
    end
  end
end
