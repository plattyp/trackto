FactoryGirl.define do
  factory :objective do
    name "MyString"
    description "MyText"
    targetgoal 100
    targetdate ""


    trait :with_progress do
      after(:create) do |objective|
        3.times do 
          create(:progress, amount: 10, objective: objective)
        end
      end
    end

    factory :objective_with_targetdate do
      targetdate Faker::Date.forward(10)
    end
  end

end
