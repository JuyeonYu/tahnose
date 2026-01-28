require "test_helper"

class PasteTest < ActiveSupport::TestCase
  test "requires password when protection enabled on new paste" do
    paste = Paste.new(body: "hello", tag: "note")
    paste.password_enabled = true

    assert_not paste.valid?
    assert paste.errors[:password].any?
  end

  test "does not require password when protection disabled" do
    paste = Paste.new(body: "hello", tag: "note")
    paste.password_enabled = false

    assert paste.valid?
  end

  test "allows updates without password when already locked" do
    paste = Paste.create!(
      body: "hello",
      tag: "note",
      password: "secret123",
      password_enabled: true
    )

    paste.body = "updated"
    paste.password = ""
    paste.password_enabled = true

    assert paste.valid?
  end
end
