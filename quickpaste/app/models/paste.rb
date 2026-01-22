class Paste < ApplicationRecord
  has_secure_password validations: false


  def locked?
    password_digest.present?
  end

  def index_display_content
    locked? ? "🔒 비밀글" : content
  end
end
