require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates presence of email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'validates presence of name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'validates uniqueness of email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'validates email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end
  end

  describe 'associations' do
    it 'has many stories as creator' do
      user = create(:user)
      story = create(:story, creator: user)
      expect(user.created_stories).to include(story)
    end

    it 'has many participants' do
      user = create(:user)
      participant = create(:participant, user: user)
      expect(user.participants).to include(participant)
    end

    it 'has many participating stories through participants' do
      user = create(:user)
      story = create(:story)
      participant = create(:participant, user: user, story: story)
      expect(user.stories).to include(story)
    end

    it 'has many comments' do
      user = create(:user)
      comment = create(:comment, user: user)
      expect(user.comments).to include(comment)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end
  end

  describe 'email normalization' do
    it 'normalizes email to lowercase' do
      user = build(:user, email: 'TEST@EXAMPLE.COM')
      user.save!
      expect(user.email).to eq('test@example.com')
    end

    it 'strips whitespace from email' do
      user = build(:user, email: '  test@example.com  ')
      user.save!
      expect(user.email).to eq('test@example.com')
    end
  end
end
