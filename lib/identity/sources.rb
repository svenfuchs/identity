require 'httparty'
require 'httparty_fix'
require 'active_support/core_ext/string/starts_ends_with'

module Identity::Sources
  autoload :Base,    'identity/sources/base'
  autoload :Hcard,   'identity/sources/hcard'
  autoload :Json,    'identity/sources/json'
  autoload :Twitter, 'identity/sources/twitter'
  autoload :Github,  'identity/sources/github'

  class << self
    def all
      @sources ||= { 'json' => Json.new, 'twitter' => Twitter.new, 'github' => Github.new }
    end
    
    def [](name)
      all[name.to_s]
    end

    def map(&block) # use Enumerable
      all.map(&block)
    end

    def each(&block)
      all.each(&block)
    end

    def each_name(&block)
      all.keys.each(&block)
    end

    def each_without(*names)
      each { |name, source| yield(name, source) unless names.include?(name) }
    end

    def update_all(identity, arguments)
      arguments.each do |arg| 
        arg.starts_with?('http://') ? update_from_url(identity, arg) : update_from_named(identity, arg)
      end
    end
    
    def update_from_url(identity, url)
      each { |name, source| handle = source.recognize_url(url) and return source.update(identity, handle) }
      all['json'].update(identity, url)
    end

    def update_from_named(identity, arg)
      ix     = arg.index(':')
      source = arg[0..ix - 1]
      handle = arg[ix + 1..-1]
      update_from_source(identity, source, handle)
    end
    
    def update_from_source(identity, source, handle)
      self[source].update(identity, handle) if handle
    end
  end
end
