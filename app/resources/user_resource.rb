class UserResource < JSONAPI::Resource
  attributes :name, :email, :leader_id
end
