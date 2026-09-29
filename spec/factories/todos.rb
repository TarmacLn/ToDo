FactoryBot.define do
  factory :todo do
    title { Faker::Lorem.sentence(word_count: 3) }
    user
  end
end
