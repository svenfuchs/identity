require 'twibot'
require 'httparty_fix'
require 'simply_stored/couch'
require 'active_support/core_ext/time/conversions' # twitter4r implicitely uses to_formatted_s
require 'active_support/core_ext/hash/keys'        # simply_stored implicitely uses assert_valid_keys


class Identity
  autoload :Sources, 'identity/sources'

  include SimplyStored::Couch

  class << self
    def get(url)
      HTTParty.get(url)
    end

    def update(handle, message)
      identity = find_by_handle(handle) || new
      dispatch(identity, parse_args(message))
      identity.save
    end

    def dispatch(identity, args)
      args.each do |source, arg|
        Sources.map[source].update(identity, arg) if Sources.map.key?(source) # queue this ...
      end
    end

    def parse_args(string)
      string.scan(/[^\s]+:[^\s]*/).inject({}) do |args, token|
        ix = token.index(':')
        args[token[0, ix]] = token[ix + 1..-1] if ix
        args
      end
    end
  end

  # sanitize data ...

  property :sources

  view :by_handle, :key => :handle, :type => :custom, :map => <<-js
    function(doc) {
      if(doc.ruby_class && doc.ruby_class == 'Identity') {
        for(name in doc['sources']) {
          if(doc['sources'][name]['handle']) {
            emit(doc['sources'][name]['handle'], doc);
          }
        }
      }
    }
  js

  def initialize(sources = {})
    @sources = sources
  end

  Sources.map.keys.each do |name|
    define_method(name) { sources[name] || {} }
    define_method(:"#{name}=") { |source| sources[name] = source }
  end

  def set_source(name, data)
    data['claimed_at'] = sources[name] ? send(name)['claimed_at'] : Time.now
    sources[name] = data
  end
end
