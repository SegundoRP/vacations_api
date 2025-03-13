module ResponseUtils
  extend ActiveSupport::Concern

  def validate_user_logged_in
    unless current_user
      error_response_json('unauthorized', :unauthorized, I18n.t('users.unauthorized'))
    end
  end

  def error_response_json(code, status, *errors)
    render json: {
      errors: errors.flatten.uniq.compact_blank.map do |error|
        {
          code: code,
          detail: error,
        }
      end,
    }, status: status.to_sym
  end

  def json_api_serialize_collection(resource_klass, *records, **params)
    records = records.flatten

    resources = records.map { |record| resource_klass.new(record, nil) }

    JSONAPI::ResourceSerializer.new(resource_klass, **params).serialize_to_hash(resources)
  end

  def json_api_serialize_object(resource_klass, record, **params)
    resource = resource_klass.new(record, nil)

    JSONAPI::ResourceSerializer.new(resource_klass, **params).serialize_to_hash(resource)
  end
end
