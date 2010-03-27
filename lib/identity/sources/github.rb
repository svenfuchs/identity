require 'active_support/core_ext/string/starts_ends_with'

module Identity::Sources
  class Github < Base
    def initialize
      @map = {
        'login'    => 'handle',
        'name'     => 'name',
        'email'    => 'email',
        'blog'     => 'url',
        'location' => 'location',
        'company'  => 'company',
        'gravatar' => 'gravatar_id'
      }
    end
    
    def recognize_url(url)
      url =~ %r(http://github.com/([^/]*)) and $1
    end

    def profile_url(profile)
      "http://github.com/#{profile['handle']}"
    end
    
    def source_url(handle)
      "http://github.com/api/v2/json/user/show/#{handle}"
    end

    def fetch(source_url)
      remap(Base.get(source_url)['user'])
    end
  end
end
