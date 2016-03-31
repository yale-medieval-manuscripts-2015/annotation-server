namespace :manifests do

  task :update_canvases => :environment do
    Manifest.each {  |manifest|
      Canvas.update_canvases_for_manifest(manifest)
    }
  end

end
