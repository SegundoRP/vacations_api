class Api::V1::UsersController < ApplicationController
  include ResponseUtils

  before_action :validate_user_logged_in
  before_action :set_user, only: %i[vacation_days]

  def vacation_days
    year = params[:year].to_i
    days = @user.vacation_days_by_year(year)

    render json: { user_id: @user.id, name: @user.name, year: year, vacation_days: days }, status: :ok
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])

    render json: { error: I18n.t("users.not_found") }, status: :not_found if @user.blank?
  end
end
