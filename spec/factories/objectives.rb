FactoryGirl.define do
  factory :objective do
    name "MyString"
  description "MyText"
  targetgoal 1

    trait :with_progress do
      after(:create) do |objective|
        3.times do 
          create(:progress, amount: 10, objective: objective)
        end
      end
    end
  end

end
