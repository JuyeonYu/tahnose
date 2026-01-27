require "test_helper"

class I18nTest < ActiveSupport::TestCase
  test "default locale is ko" do
    assert_equal :ko, I18n.default_locale
  end

  test "core translations exist in ko and en" do
    keys = %w[
      app.name
      errors.rate_limited
      flash.pastes.created
      flash.sessions.magic_link_sent
      pastes.index.title
      pastes.form.read_once_label
      mailers.magic_link.subject
      sessions.new.title
    ]

    %i[ko en].each do |locale|
      keys.each do |key|
        assert I18n.exists?(key, locale), "Missing translation: #{key} (#{locale})"
      end
    end
  end
end
