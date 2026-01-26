class LoginToken < ApplicationRecord
  belongs_to :user

  # == Constants
  EXPIRY_DURATION = 15.minutes

  # == Validations
  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :expires_at_in_future

  # == Scopes
  scope :unused, -> { where(used_at: nil) }
  scope :not_expired, -> { where("expires_at > ?", Time.current) }
  scope :active, -> { unused.not_expired }

  # == Class Methods
  # Generates a raw token and persists its digest
  # Returns the raw token (digest is stored)
  def self.generate_for!(user, request: nil)
    raw_token = SecureRandom.urlsafe_base64(32)
    digest = digest_token(raw_token)

    create!(
      user: user,
      token_digest: digest,
      expires_at: EXPIRY_DURATION.from_now,
      request_ip: request&.remote_ip,
      user_agent: request&.user_agent
    )

    raw_token
  end

  # Finds an active token record by raw token (from the URL)
  def self.find_active_by_raw_token(raw_token)
    digest = digest_token(raw_token.to_s)
    active.find_by(token_digest: digest)
  end

  # == Instance Methods
  def use!
    update!(used_at: Time.current)
  end

  def used?
    used_at.present?
  end

  def expired?
    expires_at <= Time.current
  end

  def active?
    !used? && !expired?
  end

  # == Token Digest
  def self.digest_token(raw_token)
    pepper = Rails.application.secret_key_base
    Digest::SHA256.hexdigest("#{raw_token}::#{pepper}")
  end

  private

  def expires_at_in_future
    return if expires_at.blank?
    errors.add(:expires_at, "must be in the future") if expires_at <= Time.current
  end
end
