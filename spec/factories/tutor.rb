FactoryBot.define do
  factory :tutor do
    first_name { Faker::Name.first_name  }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email(domain: 'example.com') }

    association :course
 end
end


