# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :annotation do

    add_attribute '@id',   "http://127.0.0.1:5000/annotation/#{UUID.generate}"
    add_attribute '@type', 'oa:Annotation'
    add_attribute :sequence, 1
    active  true
    version  1
    manifest 'http://manifests.ydc2.yale.edu/canvas/ThomasGray1'
    canvas 'http://manifests.ydc2.yale.edu/canvas/ThomasGray1'
    on  'http://manifests.ydc2.yale.edu/canvas/ThomasGray1#xywh=1,1,100,100'
    motivation 'oa:Describing'
    resource   {{
      '@type' => 'cnt:ContentAsText',
      'language'  => "en",
      'chars' => 'test text',
      'format' => 'text/plain'
    }}

    end
end