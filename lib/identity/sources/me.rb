module Identity::Sources
  module Me
    class << self
      def update(identity, url)
        identity.set_source('me', Identity.get(url))

        Identity::Sources.all.each do |name, source| 
          source.update(identity, identity.me[name]) if name != 'me' && identity.me[name]
        end if identity.me
      end
    end
  end
end
