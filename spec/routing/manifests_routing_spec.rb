require "spec_helper"

describe ManifestsController do
  describe "routing" do

    it "routes to #index" do
      get("/manifest").should route_to("manifests#index")
    end

    it "routes to #new" do
      get("/manifest/new").should route_to("manifests#new")
    end

    it "routes to #show" do
      get("/manifest/1").should route_to("manifests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/manifest/1/edit").should route_to("manifests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/manifest").should route_to("manifests#create")
    end

    it "routes to #update" do
      put("/manifest/1").should route_to("manifests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/manifest/1").should route_to("manifests#destroy", :id => "1")
    end

  end
end
