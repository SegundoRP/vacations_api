class TimeOffRequestResource < JSONAPI::Resource
  attributes :start_date, :end_date, :user_id, :request_type, :status, :reason

  attribute :user_name
  attribute :user_email
  attribute :user_leader_name

  def user_name
    @model.user.name
  end

  def user_email
    @model.user.email
  end

  def user_leader_name
    @model.user.leader&.name
  end
end
