FactoryGirl.define do
  factory :post do |p|
    association :user
    p.sequence(:body) { |n| "post #{n}" }
  end

end
