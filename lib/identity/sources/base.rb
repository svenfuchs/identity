require 'httparty'
require 'httparty_fix'

module Identity::Sources
  class Base
    class << self
      def get(url)
        data = HTTParty.get(url)
        data = JSON.parse(data) rescue {} if data.is_a?(String) # TODO somehow communicate parsing errors
        data['source_url'] = url
        data
      end
    end

    attr_reader :map

    def name
      self.class.name.split('::').last.downcase
    end

    def update(identity, handle)
      identity.set_profile(name, fetch(source_url(handle))) if handle
    end

    def fetch(url)
      data = Base.get(url)
      data = remap(data) if map
      data
    end

    def remap(data)
      Hash[*(data || {}).map { |key, value| [map[key], value] if map.key?(key) && value }.compact.flatten]
    end
  end
end
