class MagicLinkRequest < ApplicationRecord
  validates :email, presence: true
  validates :requested_at, presence: true

  scope :for_email, ->(email) { where(email: email.to_s.downcase) }

  def self.cooldown_remaining_seconds(email, within_seconds)
    last_requested_at = for_email(email).order(requested_at: :desc).limit(1).pick(:requested_at)
    return 0 if last_requested_at.blank?

    remaining = within_seconds - (Time.current - last_requested_at).to_i
    remaining.positive? ? remaining : 0
  end

  def self.cooldown_active?(email, within_seconds)
    cooldown_remaining_seconds(email, within_seconds).positive?
  end

  def self.record!(email:, requested_at: Time.current, ip: nil)
    create!(email: email.to_s.downcase, requested_at: requested_at, ip: ip)
  end
end
