# frozen_string_literal: true

require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "show profile" do
    login_user "hatsuno", "testtest"
    visit "/users/#{users(:hatsuno).id}"
    assert_equal "hatsunoのプロフィール | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "access by other users" do
    login_user "yamada", "testtest"
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    assert_text "管理者としてログインしてください"
  end

  test "user is canceled" do
    login_user "hatsuno", "testtest"
    visit edit_current_user_path
    click_on "退会する"
    page.driver.browser.switch_to.alert.accept
    assert_text "ログインしてください"
  end

  test "graduation date is displayed" do
    login_user "komagata", "testtest"

    visit "/users/#{users(:yamada).id}"
    assert_no_text "卒業日"

    visit "/users/#{users(:tanaka).id}"
    assert_text "卒業日"
  end

  test "retired date is displayed" do
    login_user "komagata", "testtest"
    visit "/users/#{users(:yameo).id}"
    assert_text "リタイア日"
    visit "/users/#{users(:tanaka).id}"
    assert_no_text "リタイア日"
  end

  test "user list corresponding to selected status is displayed" do
    login_user "komagata", "testtest"

    assert_text "ユーザー"
    click_link "ユーザー"

    assert_equal 6, all(".tab-nav__item-link").length
    assert_text "yamada"
    assert_text "kimura"
    assert_text "hatsuno"
    assert_text "hajime"
    assert_text "kensyu"


    assert_text "卒業生"
    click_link "卒業生"
    assert_equal 1, all(".users-item__inner").length
    assert_text "tanaka"

    assert_text "アドバイザー"
    click_link "アドバイザー"
    assert_equal 1, all(".users-item__inner").length
    assert_text "mineo"

    assert_text "全員"
    click_link "全員"
    assert_text "yameo"

    assert_text "研修生"
    click_link "研修生"
    assert_text "kensyu"
  end

  test "admin user can see unchecked number table" do
    login_user "komagata", "testtest"
    visit "/users/#{users(:komagata).id}"
    assert_equal 1, all(".admin-table").length
  end

  test "nomal user can't see unchecked number table" do
    login_user "hatsuno", "testtest"
    visit "/users/#{users(:hatsuno).id}"
    assert_equal 0, all(".admin-table").length
  end
end
