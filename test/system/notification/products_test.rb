# frozen_string_literal: true

require "application_system_test_case"

class Notification::ProductsTest < ApplicationSystemTestCase
  test "recieve a notification when product is created" do
    login_user "yamada", "testtest"
    visit "/products/new?practice_id=#{practices(:practice_5).id}"

    within("#new_product") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"
    assert_text "提出物を作成しました。"

    logout
    login_user "komagata", "testtest"

    first(".test-bell").click
    assert_text "yamadaさんが提出しました。"
  end

  test "recieve a notification when product is updated" do
    login_user "yamada", "testtest"
    visit "/products/#{products(:product_1).id}/edit"
    within("#edit_product_#{products(:product_1).id}") do
      fill_in("product[body]", with: "test")
    end
    click_button "提出する"
    assert_text "提出物を更新しました。"

    logout
    login_user "komagata", "testtest"

    first(".test-bell").click
    assert_text "yamadaさんが提出物を更新しました。"
  end

  test "recieve a notification when posted a comment to product" do
    login_user "yamada", "testtest"
    visit "/products/#{products(:product_1).id}"

    within(".thread-comment-form__form") do
      fill_in("comment[description]", with: "test")
    end
    click_button "コメントする"
    assert_text "コメントを投稿しました。"

    logout
    login_user "komagata", "testtest"

    first(".test-bell").click
    assert_text "yamadaさんが提出物にコメントしました。"
  end
end
