FactoryGirl.define do
  factory :post do |p|
    p.sequence(:body) { |n| "post #{n}" }
  end

end
