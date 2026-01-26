class Identity < ApplicationRecord
  belongs_to :user
  before_validation :normalize_provider

  # == Constants
  PROVIDERS = %w[email google_oauth2 apple].freeze

  # == Validations
  validates :provider, presence: true, inclusion: { in: PROVIDERS }

  # For OAuth providers, provider_uid (e.g., sub) must be present
  validates :provider_uid, presence: true, unless: :email_provider?

  # For email provider (magic link), email is the identifier
  validates :email, presence: true, if: :email_provider?
  validates :email, length: { maximum: 255 }, allow_nil: true

  # Ensure we don't accidentally allow duplicates at the model level;
  # DB unique indexes are still required for correctness.
  validates :provider_uid,
            uniqueness: { scope: :provider, allow_nil: true }

  validates :provider,
            uniqueness: { scope: :user_id }

  validates :email, uniqueness: { scope: :provider }, allow_nil: true

  # == Callbacks
  before_validation :normalize_email

  def email_provider?
    provider == "email"
  end

  def oauth_provider?
    !email_provider?
  end

  private

  def normalize_provider
    self.provider = provider.to_s.strip.downcase.presence
  end

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
