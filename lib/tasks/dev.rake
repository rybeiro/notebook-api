namespace :dev do
  desc "Configuração de dados para o ambiente de desenvolvimento"
  task setup: :environment do
    kinds = %w(Amigo Comercial Outro)
    kinds.each do |kind|
      Kind.create!(
        description: kind
      )
    end

    100.times do |i|
      Contact.create!(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        birthday: Faker::Date.birthday(min_age: 18, max_age: 65),
        kind: Kind.all.sample
      )
    end

    Contact.all.each do |contact|
      Random.rand(5).times do |i|
        Phone.create!(
          number: Faker::PhoneNumber.phone_number,
          contact: contact
        )
      end
    end
  end
end
