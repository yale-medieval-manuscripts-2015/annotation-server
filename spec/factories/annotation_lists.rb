# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :annotation_list do

    canvas 'http://manifests.ydc2.yale.edu/canvas/ThomasGray1'
    motivation 'oa:Describing'

    block = Proc.new { "http://127.0.0.1:5000/list/#{UUID.generate}" }

    trait :inaccessible_project_id do
      project_id 'inaccessible'
      add_attribute('@id', nil, &block)
    end

    trait :accessible_project_id do
      project_id 'accessible'
      add_attribute('@id', nil, &block)
    end

    factory :accessible_list, traits: [:accessible_project_id]
    factory :inaccessible_list, traits: [:inaccessible_project_id]
  end
end
