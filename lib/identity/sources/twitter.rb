module Identity::Sources
  module Twitter
    MAP = {
      'screen_name'       => 'handle',
      'name'              => 'name',
      'url'               => 'url',
      'location'          => 'location',
      'time_zone'         => 'time_zone',
      'profile_image_url' => 'avatar'
    }

    class << self
      def update(identity, handle)
        identity.set_source('twitter', fetch(handle)) if handle
      end
      
      def fetch(handle)
        sources = Identity.get("http://api.twitter.com/1/users/show/#{handle}.json") || {}
        Hash[*sources.map { |key, value| [MAP[key], value] if MAP.key?(key) && value }.compact.flatten]
      end
    end
  end
end
