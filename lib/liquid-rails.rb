require 'liquid-rails/version'
require 'liquid'
require 'liquid-rails/liquid_monkey_patch'
require 'kaminari'
require 'active_support/concern'
require 'active_record'

module Liquid
  module Rails
    autoload :TemplateHandler,  'liquid-rails/template_handler'
    autoload :FileSystem,       'liquid-rails/file_system'

    autoload :Drop,             'liquid-rails/drops/drop'
    autoload :CollectionDrop,   'liquid-rails/drops/collection_drop'

    def self.setup_drop(base)
      base.class_eval do
        include Liquid::Rails::Droppable
      end
    end
  end
end

require 'liquid-rails/railtie' if defined?(Rails)
Dir[File.dirname(__FILE__) + '/liquid-rails/{filters,tags,drops}/*.rb'].each { |f| require f }
