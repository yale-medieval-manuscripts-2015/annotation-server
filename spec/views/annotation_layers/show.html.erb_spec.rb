require 'spec_helper'

describe "annotation_layers/show" do
  before(:each) do
    @annotation_layer = assign(:annotation_layer, stub_model(AnnotationLayer,
      :uri => "Uri",
      :label => "Label",
      :motivation => "Motivation",
      :description => "MyText",
      :attribution => "MyText",
      :license => "License"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Identifier \(URI\)/)
    rendered.should match(/Label/)
    rendered.should match(/Motivation/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/License/)
  end
end
