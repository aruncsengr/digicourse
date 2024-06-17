FactoryBot.define do
  factory :course do
    title { Faker::Educator.course_name }
    description { Faker::Lorem.paragraph }

    trait :with_tutors do
      transient do
        tutors_count { 2 }
      end

      after(:create) do |course, evaluator|
        create_list(:tutor, evaluator.tutors_count, course: course)
      end
    end
 end
end
