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

    def url(handle)
      "http://github.com/api/v2/json/user/show/#{handle}"
    end

    def fetch(url)
      remap(Base.get(url)['user'])
    end
  end
end
