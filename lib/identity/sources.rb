module Identity::Sources
  autoload :Me,      'identity/sources/me'
  autoload :Twitter, 'identity/sources/twitter'
  autoload :Github,  'identity/sources/github'

  class << self
    def all
      @sources ||= {
        'me'      => Me,
        'twitter' => Twitter,
        'github'  => Github
      }
    end

    def each(&block)
      all.each(&block)
    end
  end
end
