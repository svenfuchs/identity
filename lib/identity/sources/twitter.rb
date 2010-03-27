module Identity::Sources
  class Twitter < Base
    def initialize
      @map = {
        'screen_name'       => 'handle',
        'name'              => 'name',
        'url'               => 'url',
        'location'          => 'location',
        'time_zone'         => 'time_zone',
        'profile_image_url' => 'avatar'
      }
    end
    
    def recognize_url(url)
      url =~ %r(http://twitter.com/([^/]*)) and $1
    end

    def profile_url(profile)
      "http://twitter.com/#{profile['handle']}"
    end
    
    def source_url(handle)
      "http://api.twitter.com/1/users/show/#{handle}.json"
    end
  end
end
