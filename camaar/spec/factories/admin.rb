FactoryBot.define do
  factory :admin do
    email { "test@gmail.com" }
    password {'abc123'}
    password_confirmation {'abc123'}
    confirmed_at {Time.now.utc}
  end
end
