FactoryGirl.define do
  factory :objective do
    name "MyString"
    description "MyText"
    targetgoal 1
    targetdate ""


    trait :with_progress do
      after(:create) do |objective|
        3.times do 
          create(:progress, amount: 10, objective: objective)
        end
      end
    end

    factory :objective_with_targetdate do
      targetdate "2015-05-03".to_date
    end
  end

end
