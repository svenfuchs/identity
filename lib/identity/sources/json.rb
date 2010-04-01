module Identity::Sources
  class Json < Base
    def update(identity, url)
      json = identity.set_profile('json', fetch(url))

      # i.e. when the json defines a github handle, we'll pull the github profile
      Identity::Sources.update_from_source(identity, 'github', json['github']) if json
    end

    def profile_url(profile)
      profile['source_url']
    end
  end
end
