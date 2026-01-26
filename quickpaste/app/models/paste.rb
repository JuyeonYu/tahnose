require "stringio"

class Paste < ApplicationRecord
  MAX_QR_BYTES = 1200  # 시작값(예시). 운영하면서 조절
  validate :content_bytesize_within_limit
  has_secure_password validations: false

  belongs_to :owner, class_name: "User", optional: true
  has_one_attached :qr_image
  after_commit :ensure_qr_image!, on: [ :create, :update ]

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

  def ensure_qr_image!
    return if content.blank?

    # content가 변경되지 않았고 이미 qr_image가 있으면 재생성하지 않음
    if persisted? && !saved_change_to_content? && qr_image.attached?
      return
    end

    png = build_qr_png(content)

    qr_image.attach(
      io: StringIO.new(png),
      filename: "paste-#{id || 'new'}.png",
      content_type: "image/png"
    )
  rescue RQRCode::QRCodeRunTimeError => e
    Rails.logger.warn(
      "[Paste##{id}] QR generation failed: #{e.class}: #{e.message} " \
      "(bytes=#{content.bytesize}, sample=#{content.to_s[0, 40].inspect})"
    )
    nil
  end

  private

  def build_qr_png(text)
    # level: :l (최대 용량) / :m (조금 더 안정적) — 필요하면 바꿔도 됨
    qrcode = RQRCode::QRCode.new(text, level: :l)

    # rqrcode_png (or rqrcode의 png renderer) 필요
    qrcode.as_png(
      border_modules: 2,
      module_px_size: 6
    ).to_s
  end

  def content_bytesize_within_limit
    return if content.blank?

    if content.bytesize > MAX_QR_BYTES
      errors.add(:content, "은(는) #{MAX_QR_BYTES} bytes 이하여야 합니다. (현재: #{content.bytesize} bytes)")
    end
  end
end
