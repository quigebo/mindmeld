class Message < ApplicationRecord
  acts_as_message

  has_many_attached :attachments

  validates :role, presence: true
  validates :chat, presence: true
end
