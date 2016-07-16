FactoryGirl.define do
  factory :user do |u|
    u.sequence(:email) { |n| "example#{n}@gmail.com" }
    password { Faker::Internet.password(8) }
    password_confirmation { password }
  end

end
