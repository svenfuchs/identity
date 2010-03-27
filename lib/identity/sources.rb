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
      all[name]
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

    def update_all(identity, args)
      args.each { |arg| arg.starts_with?('http://') ? update_url(identity, arg) : update_named(identity, arg) }
    end
    
    def update_url(identity, url)
      each { |name, source| handle = source.recognize_url(url) and return source.update(identity, handle) }
      all['json'].update(identity, url)
    end

    def update_named(identity, arg)
      ix    = arg.index(':')
      name  = arg[0..ix - 1]
      value = arg[ix + 1..-1]
      self[name].update(identity, value)
    end
  end
end
