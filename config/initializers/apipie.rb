Apipie.configure do |config|
  config.app_name                = "ParkingsApp"
  config.api_base_url            = ""
  config.doc_base_url            = "/api-docs"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/{**/*,*}.rb"
  config.translate      = false
  config.default_locale = nil
  config.validate = false
  config.show_all_examples = true
  config.namespaced_resources = true
  config.authenticate = Proc.new do
    authenticate_admin!
  end
end

Apipie::Application.class_eval do
  def get_resource_name(klass)
    if klass.class == String
      klass
    elsif @controller_to_resource_id.has_key?(klass)
      @controller_to_resource_id[klass]
    elsif Apipie.configuration.namespaced_resources? && klass.respond_to?(:controller_path)
      return nil if klass == ActionController::Base
      path = klass.controller_path
      path.gsub(version_prefix(klass), "-")#.gsub("/", "-")
    elsif klass.respond_to?(:controller_name)
      return nil if klass == ActionController::Base
      klass.controller_name
    else
      raise "Apipie: Can not resolve resource #{klass} name."
    end
  end
end
