# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do

    description 'This is a test project'
    thumbnailUrl 'http://scale.ydc2.yale.edu/iiif/e40742a3-f920-430d-ad5c-f6ba97b32275/1000,300,1000,1000/250,/0/native.jpg'

    miradorConfiguration [
        {
          'manifestUri' =>'http://manifests.ydc2.yale.edu/manifest/BeineckeMS10.json',
          'location' => 'Yale University',
          'title' =>'Beinecke MS 10',
          'widgets' =>[]
        }
    ]

    trait :accessible do
      project_id 'accessible'
      name 'Test Project 1'
      permissions ['testProj1']
      groups ['testProj1']
    end

    trait :inaccessible do
      project_id 'inaccessible'
      name 'No Access'
      permissions ['noaccess']
      groups ['noaccess']
    end

    factory :accessible_project, traits: [:accessible]
    factory :inaccessible_project, traits: [:inaccessible]

   end
end
