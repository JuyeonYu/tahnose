class User < ApplicationRecord
  # == Associations
  has_many :identities, dependent: :destroy
  has_many :login_tokens, dependent: :destroy
  has_many :pastes, foreign_key: :owner_id, dependent: :nullify

  # == Validations
  # If you later decide to allow OAuth-only users without email, you can relax `presence: true`
  # and instead validate presence conditionally based on attached identities.
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    length: { maximum: 255 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  # == Callbacks
  before_validation :normalize_email

  private

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
