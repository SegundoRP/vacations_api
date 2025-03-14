class Api::V1::TimeOffRequestsController < ApplicationController
  include ResponseUtils

  before_action :validate_user_logged_in
  before_action :set_time_off_request, only: %i[show update destroy]

  def index
    page = (params[:page] || 1).to_i
    per_page = params[:per_page].to_i
    per_page = per_page.positive? ? per_page : 1000

    @search = TimeOffRequest.includes(user: :leader).order(start_date: :asc).ransack(params[:filters])
    time_off_requests = @search.result.page(page).per(per_page)

    response_json = {
      time_off_requests: json_api_serialize_collection(TimeOffRequestResource, *time_off_requests),
      pagination: {
        current_page: time_off_requests.current_page,
        total_pages: time_off_requests.total_pages,
        total_count: time_off_requests.total_count,
        per_page: per_page,
      },
    }

    render json: response_json, status: :ok
  end

  def show
    render json: json_api_serialize_object(TimeOffRequestResource, @time_off_request), status: :ok
  end

  def create
    time_off_request = TimeOffRequest.new(time_off_request_params)
    if time_off_request.save
      render json: json_api_serialize_object(TimeOffRequestResource, time_off_request), status: :created
    else
      error_response_json('validation_error', :bad_request, time_off_request.errors.full_messages)
    end
  end

  def update
    if @time_off_request.update(time_off_request_params)
      render json: json_api_serialize_object(TimeOffRequestResource, @time_off_request), status: :ok
    else
      error_response_json('validation_error', :bad_request, @time_off_request.errors.full_messages)
    end
  end

  def destroy
    if @time_off_request.destroy
      head :no_content
    else
      error_response_json('validation_error', :bad_request, @time_off_request.errors.full_messages)
    end
  end

  private

  def set_time_off_request
    @time_off_request = TimeOffRequest.find_by(id: params[:id])

    render json: { error: I18n.t('time_off_requests.not_found') }, status: :not_found if @time_off_request.blank?
  end

  def time_off_request_params
    params.require(:time_off_request).permit(:start_date, :end_date, :user_id, :request_type, :status, :reason)
  end
end
