require "spec_helper"

describe AnnotationLayersController do
  describe "routing" do

    it "routes to #index" do
      get("/layer").should route_to("annotation_layers#index")
    end

    it "routes to #new" do
      get("/layer/new").should route_to("annotation_layers#new")
    end

    it "routes to #show" do
      get("/layer/1").should route_to("annotation_layers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/layer/1/edit").should route_to("annotation_layers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/layer").should route_to("annotation_layers#create")
    end

    it "routes to #update" do
      put("/layer/1").should route_to("annotation_layers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/layer/1").should route_to("annotation_layers#destroy", :id => "1")
    end

  end
end
