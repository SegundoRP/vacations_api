FactoryBot.define do
  factory :time_off_request do
    start_date { Date.current }
    end_date { Date.current + 2.days }
    reason { "Time off request" }
    request_type { :vacation }
    user

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :pending do
      status { :pending }
    end

    trait :vacation do
      request_type { :vacation }
    end

    trait :incapacity do
      request_type { :incapacity }
    end
  end
end
