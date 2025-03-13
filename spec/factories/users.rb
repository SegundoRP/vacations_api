FactoryBot.define do
  factory :user do
    email { 'test@test.com' }
    password { '123456' }
    name { 'Nombre de usuario' }
    role { :normal }
    position { :employee }
  end
end
