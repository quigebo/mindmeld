class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  
  # Associations
  has_many :created_stories, class_name: 'Story', foreign_key: 'creator_id', dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :stories, through: :participants
  has_many :comments, dependent: :destroy, class_name: '::Comment'

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  # Normalize email before validation
  before_validation :normalize_email

  # OmniAuth methods
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.password = Devise.friendly_token[0, 20]
      user.avatar_url = auth.info.image
    end
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end
end
