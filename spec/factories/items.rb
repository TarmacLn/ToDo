FactoryBot.define do
  factory :item do
    name { Faker::Lorem.words(number: 2).join(" ") }
    done { false }
    todo
  end
end
