module Identity::Sources
  class Me < Base
    def update(identity, url)
      identity.set_profile('me', fetch(url))

      Identity::Sources.each_without('me') do |name, source|
        source.update(identity, identity.me[name]) if identity.me[name]
      end if identity.me
    end

    def profile_url(profile)
      profile['source_url']
    end
  end
end
