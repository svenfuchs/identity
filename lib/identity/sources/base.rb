require 'httparty'
require 'httparty_fix'

module Identity::Sources
  class Base
    class << self
      def get(url)
        HTTParty.get(url)
      end
    end

    attr_reader :map

    def name
      self.class.name.split('::').last.downcase
    end

    def update(identity, handle)
      identity.set_profile(name, fetch(url(handle))) if handle
    end

    def fetch(url)
      remap(Base.get(url))
    end

    def remap(data)
      Hash[*(data || {}).map { |key, value| [map[key], value] if map.key?(key) && value }.compact.flatten]
    end
  end
end
