class Api::V1::TimeOffRequestsController < ApplicationController
  include ResponseUtils

  before_action :validate_user_logged_in
  before_action :set_time_off_request, only: %i[show update destroy]

  def index
    @search = TimeOffRequest.includes(:user).order(start_date: :asc).ransack(params[:filters])
    time_off_requests = @search.result.page(params[:page]).per(params[:per_page])

    response_json = json_api_serialize_collection(TimeOffRequestResource, *time_off_requests)

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
