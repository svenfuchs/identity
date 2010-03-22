require 'httparty'
require 'httparty_fix'

module Identity::Sources
  autoload :Base,    'identity/sources/base'
  autoload :Me,      'identity/sources/me'
  autoload :Twitter, 'identity/sources/twitter'
  autoload :Github,  'identity/sources/github'

  class << self
    def all
      @sources ||= { 'me' => Me.new, 'twitter' => Twitter.new, 'github' => Github.new }
    end
    
    def update_all(identity, args)
      each { |name, source| source.update(identity, args[name]) if args.key?(name) }
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
  end
end
