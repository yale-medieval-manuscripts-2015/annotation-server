# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email                 "example@yahoo.com"
    password              "password"
    password_confirmation "password"
    uid                   "example@yahoo.com"
    provider              ""
    name                  "John Doe #2"
    first_name            "John"
    last_name             "Doe"
    personal_group        "email/example@yahoo.com"


    trait :project_access do
      groups  ["testProj1"]
    end

    trait :manifest_admin do
      manifest_admin  true
    end

    factory :accessible_project_user, traits: [:project_access]
    factory :manifest_admin_user, traits: [:manifest_admin]
  end
end
