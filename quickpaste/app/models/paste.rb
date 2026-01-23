class Paste < ApplicationRecord
  has_secure_password validations: false


  def locked?
    password_digest.present?
  end

  def index_display_content
    locked? ? "🔒 비밀글" : content
  end

  def ensure_manage_token!
    return if manage_token_digest.present?

    token = SecureRandom.urlsafe_base64(32) # 원문 토큰
    self.manage_token_digest = self.class.digest(token)
    self.manage_token_created_at = Time.current
    token # 생성된 "원문 토큰"은 딱 이 순간에만 반환해서 사용자에게 보여줘야 함
  end

  def valid_manage_token?(token)
    return false if manage_token_digest.blank? || token.blank?
    ActiveSupport::SecurityUtils.secure_compare(self.class.digest(token), manage_token_digest)
  end

  def self.digest(str)
    # SHA256로 충분. bcrypt를 써도 되지만 관리토큰은 "비밀번호 재입력" UX가 아니라 "링크 보관" UX라 SHA256이 간단.
    OpenSSL::Digest::SHA256.hexdigest(str)
  end
end
