gem 'cancan'

class ManifestsController < ApplicationController

  load_and_authorize_resource
  skip_load_and_authorize_resource :only => [:show, :create]

  # GET /manifests
  # GET /manifests.json
  def index
    all_manifests = Manifest.all.asc(:label)
    @manifest_ids = []
    @manifests = []
    all_manifests.each do |manifest|
      if can? :show, manifest
        @manifests.push manifest
        @manifest_ids.push ({
              '@id' => manifest['manifest_json']['@id'],
              '@type' => manifest['manifest_json']['@type'],
              label: manifest['manifest_json']['label']
          })
      end

      @collection = {
           :@context => "http://iiif.io/api/presentation/2/context.json",
           :@id => request.url,
           :@type => "sc:Collection",
           manifests: @manifest_ids
      }
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json {
        render json: @collection
      }
    end
  end

  # GET /manifests/1
  # GET /manifests/1.json
  def show
    id = params[:id]
    @auth_manifest = Manifest.only(:permissions, :updated_at).find(id)
    authorize! :show, @auth_manifest

    ts = @auth_manifest[:updated_at] || Time.now.getutc
    if stale?(:etag => id, :last_modified => ts)
      @manifest = Manifest.find(id)
      respond_to do |format|
        format.html
        format.json {
          render json: @manifest.manifest_json
        }
      end
    end
  end

  # GET /manifests/new
  # GET /manifests/new.json
  def new
    @manifest = Manifest.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @manifest }
    end
  end

  # GET /manifests/1/edit
  def edit
    @manifest = Manifest.find(params[:id])
  end

  # POST /manifests
  # POST /manifests.json
  def create
    data = params[:manifest].clone
    data[:manifest_json] = JSON.parse(data[:manifest_json]) if data[:manifest_json].is_a? String
    @manifest = Manifest.new(data)
    @manifest.id = data[:manifest_uri].gsub(/.*\/manifest\//, '')
    authorize! :manage, @manifest

    respond_to do |format|
      if @manifest.save
        Canvas.update_canvases_for_manifest(@manifest)
        format.html { redirect_to @manifest, notice: 'Manifest was successfully created.' }
        format.json { render json: @manifest, status: :created, location: @manifest }
      else
        format.html { render action: "new" }
        format.json { render json: @manifest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /manifests/1
  # PUT /manifests/1.json
  def update
    @manifest = Manifest.find(params[:id])
    authorize! :update, @manifest
    data = params[:manifest].clone
    @manifest[:updated_at] = Time.now.getutc
    data[:manifest_json] = JSON.parse(data[:manifest_json]) if data[:manifest_json].is_a? String
    respond_to do |format|
      if @manifest.update_attributes(data)
        Canvas.update_canvases_for_manifest(@manifest)
        format.html { redirect_to @manifest, notice: 'Manifest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @manifest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manifests/1
  # DELETE /manifests/1.json
  def destroy
    @manifest = Manifest.find(params[:id])
    @manifest.destroy

    respond_to do |format|
      format.html { redirect_to manifests_url }
      format.json { head :no_content }
    end
  end

  protected

  def base_uri
    base_uri = Rails.configuration.annotation_server.url
    base_uri += '/' unless base_uri.ends_with?('/')
    base_uri
  end
end
