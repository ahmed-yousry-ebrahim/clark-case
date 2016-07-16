FactoryGirl.define do
  factory :comment do |c|
    association :post
    c.sequence(:text) { |n| "comment #{n}" }
  end

end
