# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  uuid = UUID.generate
  uri = "http://127.0.0.1:5000/manifest/#{uuid}"

  factory :manifest do
    label "MyString"
    description "MyString"
    manifest_uri  uri
    manifest_json { {'@id' => uri} }
    permissions { { } }
    id  { uuid }
  end
end
