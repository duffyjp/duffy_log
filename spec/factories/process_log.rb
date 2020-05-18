FactoryBot.define do
  factory :process_log, class: ProcessLog do
    key "import"

    trait :success do
      start_time { Time.now - rand(60).minutes }
      status "Success"
      end_time { Time.now }
    end

    trait :fail do
      start_time { Time.now - rand(60).minutes }
      status "Fail"
      end_time { Time.now }
    end
  end
end
