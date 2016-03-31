# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :annotation_layer do
    add_attribute '@id', "http://127.0.0.1:5000/list/#{UUID.generate}"
    label "Test Layer"
    motivation "oa:Describing"
    description "Test Description"
    attribution "Test Attribution"
    license "http://www.example.com/"
  end
end
