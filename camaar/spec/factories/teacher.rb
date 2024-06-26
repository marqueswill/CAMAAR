FactoryBot.define do
  factory :teacher do
    created_at { Time.now.utc }
    updated_at { Time.now.utc }

    trait :teacher1 do
      id { 100 }
      registration { 27_612_295_172 }
      name { 'FERNANDO CHACON' }
      formation { 'DOUTORADO' }
      occupation { 'docente' }
      email { 'chacon@unb.br' }
      department_id { 508 }
      user_id { 100 }
    end

    trait :teacher2 do
      id { 6 }
      registration { 83_807_519_491 }
      name { 'MARISTELA HOLANDA' }
      formation { 'DOUTORADO' }
      occupation { 'docente' }
      email { 'mholanda@unb.br' }
      department_id { 508 }
      user_id { 6 }
    end
  end
end
