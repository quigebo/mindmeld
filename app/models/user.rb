class User < ApplicationRecord
  # Associations
  has_many :created_stories, class_name: 'Story', foreign_key: 'creator_id', dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :stories, through: :participants
  has_many :comments, dependent: :destroy, class_name: '::Comment'

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  # Normalize email before saving
  before_save :normalize_email

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end
end
