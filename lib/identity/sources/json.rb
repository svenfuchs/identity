module Identity::Sources
  class Json < Base
    def update(identity, url)
      identity.set_profile('json', fetch(url))

      Identity::Sources.each_without('json') do |name, source|
        source.update(identity, identity.json[name]) if identity.json[name]
      end if identity.json
    end

    def profile_url(profile)
      profile['source_url']
    end
  end
end
