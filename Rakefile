require "bundler/gem_tasks"
require 'open-uri'
require 'json'
require 'ari/generators/resource_generator'

desc "Generate resources from JSON specification"
task :generate do

  base_url = 'http://svn.asterisk.org/svn/asterisk/trunk/rest-api/api-docs/%{resource_name}.json'
  resources = %w{ applications asterisk bridges channels deviceStates endpoints
    events mailboxes playbacks recordings sounds
  }

  resource_options = {
    asterisk: {
      resource_klass_name: 'AsteriskInfo'
    },
    applications: {
      id_attribute_name: 'applicationName'
    },
    events: {
      only_models: true
    }
  }

  models_path = File.join(__dir__, 'lib', 'ari', 'models.rb')
  FileUtils.rm_f models_path
  models_file = File.new(models_path, 'a')

  resources_path = File.join(__dir__, 'lib', 'ari', 'resources.rb')
  FileUtils.rm_f resources_path
  resources_file = File.new(resources_path, 'a')

  resources.each do |resource_name|
    url = base_url % { resource_name: resource_name }
    puts ">> generating #{resource_name} from #{url}"
    json = JSON.parse open(url).read
    generator = Ari::Generators::ResourceGenerator.new(
      resource_name,
      json,
      resource_options[resource_name.to_sym] || {}
    )
    generator.generate

    resources_file.puts "require 'ari/resources/#{generator.resource_name}'"
    generator.models.each do |model|
      next if model.name == generator.resource_name
      models_file.puts "require 'ari/models/#{model.name}'"
    end
  end

  models_file.close

end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

task :default => :test
