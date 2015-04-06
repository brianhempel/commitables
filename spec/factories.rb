# This will guess the User class
FactoryGirl.define do
  factory :table do
    sequence(:name) { |n| "Table #{n}"}
    head { Commit.root }
  end
end
