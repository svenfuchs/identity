require 'httparty'
require 'httparty_fix'
require 'active_support/core_ext/string/starts_ends_with'

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

    def update(identity, arg, data = nil)
      url = arg.starts_with?('http') ? arg : source_url(arg)
      data ||= fetch(url)
      identity.set_profile(name, data)
    end

    def recognize_url(url)
      nil
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
