# frozen_string_literal: true

class ReportsController < ApplicationController
  include ReportsHelper
  include Rails.application.routes.url_helpers
  before_action :require_login
  before_action :set_report, only: %i(show)
  before_action :set_my_report, only: %i(edit update destroy)
  before_action :set_checks, only: %i(show)
  before_action :set_check, only: %i(show)
  before_action :set_footprints, only: %i(show)
  before_action :set_footprint, only: %i(show)
  before_action :set_user, only: %i(show)
  before_action :set_categories, only: %i(new create edit update)

  def index
    @search_words = params[:word]&.squish&.split(/[[:blank:]]/)&.uniq
    @reports = Report.eager_load(:user, :comments, checks: :user).default_order.page(params[:page])

    if params[:practice_id].present?
      @reports = @reports.joins(:practices).where(practices: { id: params[:practice_id] })
    end

    if @search_words.present?
      @reports = @reports.ransack(title_or_description_cont_all: @search_words).result
    end
  end

  def show
    footprint!
  end

  def new
    @report = Report.new(reported_on: Date.current)
    @report.learning_times.build()

    if params[:id]
      report              = current_user.reports.find(params[:id])
      @report.title       = report.title
      @report.reported_on = Date.current
      @report.description = report.description
      @report.practices   = report.practices
    end
  end

  def edit
    @report.user = current_user
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    set_wip
    if @report.save
      notify_to_slack(@report)
      redirect_to redirect_url(@report), notice: notice_message(@report)
    else
      render :new
    end
  end

  def update
    set_wip
    if @report.update(report_params)
      redirect_to redirect_url(@report), notice: notice_message(@report)
    else
      render :edit
    end
  end

  def destroy
    @report.destroy
    redirect_to reports_url, notice: "日報を削除しました。"
  end

  private
    def footprint!
      @report.footprints.where(user: current_user).first_or_create if @report.user != current_user
    end

    def report_params
      params.require(:report).permit(
        :title,
        :reported_on,
        :description,
        practice_ids: [],
        learning_times_attributes: [:id, :started_at, :finished_at, :_destroy]
      )
    end

    def set_report
      @report = Report.find(params[:id])
    end

    def set_my_report
      @report = current_user.reports.find(params[:id])
    end

    def set_user
      @user = User.find_by(id: params[:user_id])
    end

    def set_check
      @check = Check.new
    end

    def report
      @report ||= Report.find(params[:id])
    end

    def set_checks
      @checks = report.checks.order(created_at: :desc)
    end

    def set_footprint
      @footprint = Footprint.new
    end

    def set_footprints
      @footprints = @report.footprints.order(created_at: :desc)
    end

    def set_categories
      @categories = Category.eager_load(:practices).where.not(practices: { id: nil }).order("categories.position ASC, practices.position ASC")
    end

    def notify_to_slack(report)
      name = "#{report.user.login_name}"
      link = "<#{report_url(report)}|#{report.title}>"

      notify "#{name} created #{link}",
        username: "#{report.user.login_name} (#{report.user.full_name})",
        icon_url: url_for(report.user.avatar),
        attachments: [{
          fallback: "report body.",
          text: report.description
        }]
    end

    def set_wip
      @report.wip = params[:commit] == "WIP"
    end

    def redirect_url(report)
      report.wip? ? edit_report_url(report) : report
    end

    def notice_message(report)
      report.wip? ? "日報をWIPとして保存しました。" : "日報を保存しました。"
    end
end
