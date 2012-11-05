namespace :sunspot do
  namespace :mongo do
    desc "Reindex all models that include Sunspot::Mongo and are located in your application's models directory."
    task :reindex, [:models] => :environment do |t, args|
      require 'retryable'
      sunspot_models = if args[:models]
         args[:models].split('+').map{|m| m.constantize}
      else
        all_files = Dir.glob(Rails.root.join('app', 'models', '*.rb'))
        all_models = all_files.map { |path| File.basename(path, '.rb').camelize.constantize }
        all_models.select { |m| m.include?(Sunspot::Mongo) and m.searchable? }
      end

      sunspot_models.each do |model|
        model.remove_all_from_index!
        # Sunspot.commit
        puts "reindexing #{model}"
        model.all.each do |m|
          retryable on: RSolr::Error::Http, times: 5, sleep: 5 do
            m.index
          end
        end
        
        retryable on: RSolr::Error::Http, times: 5, sleep: 5 do
          Sunspot.commit
        end
      end
    end
  end
end