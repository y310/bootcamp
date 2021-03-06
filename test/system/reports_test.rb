# frozen_string_literal: true

require "application_system_test_case"

class ReportsTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"

    @practice_titles = Category.all.order(:position).inject([]) do |sum, category|
      sum + category.practices.pluck(:title)
    end
  end

  test "create report as WIP" do
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
    end
    click_button "WIP"
    assert_text "日報をWIPとして保存しました。"
  end

  test "create a report" do
    visit "/reports/new"
    within("#new_report") do
      fill_in("report[title]", with: "test title")
      fill_in("report[description]",   with: "test")
    end

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"
    assert_text "日報を保存しました。"
  end

  test "equal practices order in practices and new report" do
    visit "/reports/new"
    first(".select2-selection--multiple").click
    report_practices = page.all(".select2-results__option").map { |e| e.text }
    assert_equal report_practices.count, Practice.count
    assert_match /OS X Mountain Lionをクリーンインストールする$/, first(".select2-results__option").text
    assert_match /Unityでのテスト$/, all(".select2-results__option").last.text
  end

  test "equal practices order in practices and edit report" do
    visit "/reports/#{reports(:report_1).id}/edit"
    first(".select2-selection--multiple").click
    report_practices = page.all(".select2-results__option").map { |e| e.text }
    assert_equal report_practices.count, Practice.count
    assert_match /OS X Mountain Lionをクリーンインストールする$/, first(".select2-results__option").text
    assert_match /Unityでのテスト$/, all(".select2-results__option").last.text
  end

  test "issue #360 duplicate" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("08")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("09")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("30")

    click_link "学習時間追加"
    all(".learning-time")[2].all(".learning-time__started-at select")[0].select("19")
    all(".learning-time")[2].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[2].all(".learning-time__finished-at select")[0].select("20")
    all(".learning-time")[2].all(".learning-time__finished-at select")[1].select("15")

    click_button "提出"

    assert_text "2時間45分"
    assert_text "07:30 〜 08:30"
    assert_text "08:30 〜 09:30"
    assert_text "19:30 〜 20:15"
  end

  test "register learning_times 2h" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("08")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("09")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"

    assert_text "2時間\n"
    assert_text "07:30 〜 08:30"
    assert_text "08:30 〜 09:30"
  end

  test "register learning_times 1h40m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("07")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("08")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("30")

    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("19")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("20")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("15")

    click_button "提出"

    assert_text "1時間45分\n"
    assert_text "07:30 〜 08:30"
    assert_text "19:30 〜 20:15"
  end

  test "register learning_time 45m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報 成功"
    fill_in "report_description", with: "不具合再現の結合テストコード"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("19")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("20")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("15")

    click_button "提出"

    assert_text "45分\n"
    assert_text "19:30 〜 20:15"
  end

  test "register learning_times 1h" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "完了日時 - 開始日時 < 0のパターン"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("23")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("00")

    click_button "提出"

    assert_text "1時間\n"
    assert_text "23:00 〜 00:00"
  end

  test "register learning_times 4h" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "複数時間登録のパターン"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("22")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("00")

    click_link "学習時間追加"
    all(".learning-time")[1].all(".learning-time__started-at select")[0].select("00")
    all(".learning-time")[1].all(".learning-time__started-at select")[1].select("30")
    all(".learning-time")[1].all(".learning-time__finished-at select")[0].select("02")
    all(".learning-time")[1].all(".learning-time__finished-at select")[1].select("30")

    click_button "提出"

    assert_text "4時間\n"
    assert_text "22:00 〜 00:00"
    assert_text "00:30 〜 02:30"
  end

  test "can't register learning_times 0h0m" do
    visit "/reports/new"
    fill_in "report_title", with: "テスト日報"
    fill_in "report_description", with: "can't register learning_times 0h0m"

    all(".learning-time")[0].all(".learning-time__started-at select")[0].select("22")
    all(".learning-time")[0].all(".learning-time__started-at select")[1].select("00")
    all(".learning-time")[0].all(".learning-time__finished-at select")[0].select("22")
    all(".learning-time")[0].all(".learning-time__finished-at select")[1].select("00")

    click_button "提出"

    assert_text "終了時間は開始時間より後にしてください"
  end

  test "reports can be copied" do
    user   = users(:komagata)
    report = user.reports.first
    visit report_path(report)
    travel 5.day do
      find("#copy").click
      assert_equal find("#report_reported_on").value, Date.current.strftime("%Y-%m-%d")
    end
  end

  test "previous report" do
    visit "/reports/#{reports(:report_2).id}"
    click_link "前の日報"
    assert_equal "/reports/#{reports(:report_1).id}", current_path
  end

  test "next report" do
    visit "/reports/#{reports(:report_2).id}"
    click_link "次の日報"
    assert_equal "/reports/#{reports(:report_3).id}", current_path
  end

  test "report has a comment form " do
    login_user "yamada", "testtest"
    visit "/reports/#{reports(:report_1).id}"
    assert_selector ".thread-comment-form"
  end
end
