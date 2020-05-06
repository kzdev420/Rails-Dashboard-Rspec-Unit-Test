
namespace :yard do
  task :models do
    system("bundle exec yard doc --asset doc/images:images --output-dir #{Rails.root}/doc/models ./app/models ")
  end

  task :controllers do
    system("bundle exec yard doc --output-dir #{Rails.root}/doc/controllers ./app/controllers")
  end

  task :interactions do
    system("bundle exec yard doc --output-dir #{Rails.root}/doc/interactions ./app/interactions")
  end
end
