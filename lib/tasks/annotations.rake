namespace :annotations do

  task :export_cs => :environment do
    puts "["
    Annotation.each_with_index {  |anno, index|
      if (anno['permissions']['read'].include?('yaleCS'))
        continue if anno.active == 0
        puts ',' if index > 0
        puts anno.to_iiif.to_json
      end
    }
    puts "]"
  end

end
