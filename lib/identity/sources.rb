module Identity::Sources
  autoload :Me,      'identity/sources/me'
  autoload :Twitter, 'identity/sources/twitter'
  autoload :Github,  'identity/sources/github'

  class << self
    def map
      @sources ||= {
        'me'      => Me,
        'twitter' => Twitter,
        'github'  => Github
      }
    end
  end
end