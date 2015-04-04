# This will guess the User class
FactoryGirl.define do
  factory :table do
    head { Commit.root }
  end
end
