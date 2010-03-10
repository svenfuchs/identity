module Identity::Sources
  module Github
    MAP = {
      'login'    => 'handle',
      'name'     => 'name',
      'email'    => 'email',
      'blog'     => 'url',
      'location' => 'location',
      'company'  => 'company',
      'gravatar' => 'gravatar_id'
    }

    class << self
      def update(identity, handle)
        identity.set_source('github', fetch(handle)) if handle
      end
      
      def fetch(handle)
        sources = Identity.get("http://github.com/api/v2/json/user/show/#{handle}")['user'] || {}
        Hash[*sources.map { |key, value| [MAP[key], value] if MAP.key?(key) && value }.compact.flatten]
      end
    end
  end
end
