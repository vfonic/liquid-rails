module Liquid
  # A Liquid file system is a way to let your templates retrieve other templates for use with the include tag.
  #
  # You can implement subclasses that retrieve templates from the database, from the file system using a different
  # path structure, you can provide them as hard-coded inline strings, or any manner that you see fit.
  #
  # You can add additional instance variables, arguments, or methods as needed.
  #
  # Example:
  #
  #   Liquid::Template.file_system = Liquid::LocalFileSystem.new(template_path)
  #   liquid = Liquid::Template.parse(template)
  #
  # This will parse the template with a LocalFileSystem implementation rooted at 'template_path'.
  class BlankFileSystem
    # Called by Liquid to retrieve a template file
    def read_template_file(_template_path, _context)
      raise FileSystemError, "This liquid context does not allow includes."
    end
  end

  # Context keeps the variable stack and resolves variables, as well as keywords
  #
  #   context['variable'] = 'testing'
  #   context['variable'] #=> 'testing'
  #   context['true']     #=> true
  #   context['10.2232']  #=> 10.2232
  #
  #   context.stack do
  #      context['bob'] = 'bobsen'
  #   end
  #
  #   context['bob']  #=> nil  class Context
  class Context
    # Fetches an object starting at the local scope and then moving up the hierachy
    def find_variable(key)
      # This was changed from find() to find_index() because this is a very hot
      # path and find_index() is optimized in MRI to reduce object allocation
      index = @scopes.find_index { |s| s.key?(key) }
      scope = @scopes[index] if index

      variable = nil

      if scope.nil?
        variable_is_nil = @environments.any? { |e| e.has_key?(key) && e[key].nil? }
        unless variable_is_nil
          @environments.each do |e|
            variable = lookup_and_evaluate(e, key)
            unless variable.nil?
              scope = e
              break
            end
          end
        end
      end

      scope ||= @environments.last || @scopes.last
      variable ||= lookup_and_evaluate(scope, key) unless variable_is_nil

      variable = variable.to_liquid
      variable.context = self if variable.respond_to?(:context=)

      variable
    end
  end

  class Include < Tag
    def read_template_from_file_system(context)
      @variable_name_expr = ''
      file_system = context.registers[:file_system] || Liquid::Template.file_system

      file_system.read_template_file(context.evaluate(@template_name_expr), context)
    end
  end

  # This implements an abstract file system which retrieves template files named in a manner similar to Rails partials,
  # ie. with the template name prefixed with an underscore. The extension ".liquid" is also added.
  #
  # For security reasons, template paths are only allowed to contain letters, numbers, and underscore.
  #
  # Example:
  #
  #   file_system = Liquid::LocalFileSystem.new("/some/path")
  #
  #   file_system.full_path("mypartial")       # => "/some/path/_mypartial.liquid"
  #   file_system.full_path("dir/mypartial")   # => "/some/path/dir/_mypartial.liquid"
  #
  # Optionally in the second argument you can specify a custom pattern for template filenames.
  # The Kernel::sprintf format specification is used.
  # Default pattern is "_%s.liquid".
  #
  # Example:
  #
  #   file_system = Liquid::LocalFileSystem.new("/some/path", "%s.html")
  #
  #   file_system.full_path("index") # => "/some/path/index.html"
  #
  class LocalFileSystem
    def read_template_file(template_path, _context)
      full_path = full_path(template_path)
      raise FileSystemError, "No such template '#{template_path}'" unless File.exist?(full_path)

      File.read(full_path)
    end
  end
end
