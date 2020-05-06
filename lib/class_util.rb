module ClassUtil
  def self.models
    @models ||= load_models
  end

  def self.load_models
    models = []

    Rails.application.paths['app/models'].each do |models_path|
      Dir["#{models_path}/**/*.rb"].each_with_object(models) do |file, memo|
        next if file =~/models\/concerns/

        klass = file.gsub(models_path, '').gsub('.rb', '').camelize.safe_constantize

        if klass.present? && klass < ApplicationRecord && !klass.abstract_class?
          memo << klass
        end
      end
    end

    models
  end

  singleton_class.send(:private, :load_models)
end
