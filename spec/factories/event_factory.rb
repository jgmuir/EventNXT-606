FactoryBot.define do
  factory :event do
    title { Faker::Lorem.word }
    address { Faker::Address.full_address }
    datetime { Faker::Date.forward }
    description { Faker::Lorem.paragraph }
    last_modified { Faker::Date.backward }

    files = Dir.glob('spec/fixtures/files/img/**/*').reject {|f| File.directory?(f)}
    image { Rack::Test::UploadedFile.new(fp, Rack::Mime.mime_type(File.extname(files.sample))) }
  end
end