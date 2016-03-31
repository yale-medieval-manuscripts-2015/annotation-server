require 'spec_helper'

describe "annotation_layers/index" do
  before(:each) do
    assign(:annotation_layers, [
      stub_model(AnnotationLayer,
        :@id=> "Uri",
        :label => "Label",
        :motivation => "Motivation",
        :description => "Description",
        :attribution => "Attribution",
        :license => "License"
      ),
      stub_model(AnnotationLayer,
        :@id => "Uri",
        :label => "Label",
        :motivation => "Motivation",
        :description => "Description",
        :attribution => "Attribution",
        :license => "License"
      )
    ])
  end

  it "renders a list of annotation_layers" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Uri".to_s, :count => 2
    assert_select "tr>td", :text => "Label".to_s, :count => 2
    assert_select "tr>td", :text => "Motivation".to_s, :count => 2
  end
end
