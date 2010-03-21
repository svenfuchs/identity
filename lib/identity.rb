require 'simply_stored/couch'
require 'active_support/core_ext/time/conversions' # twitter4r implicitely uses to_formatted_s
require 'active_support/core_ext/hash/keys'        # simply_stored implicitely uses assert_valid_keys

class Identity
  autoload :Command,  'identity/command'
  autoload :Listener, 'identity/listener'
  autoload :Poller,   'identity/poller'
  autoload :Sources,  'identity/sources'

  include SimplyStored::Couch

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

  def update(args)
    Sources.each { |name, source| source.update(self, args[name]) if args.key?(name) }
  end

  Sources.each do |name, source|
    define_method(name) { sources[name] || {} }
    define_method(:"#{name}=") { |source| sources[name] = source }
  end

  def set_source(name, data)
    data['claimed_at'] = sources[name] ? send(name)['claimed_at'] : Time.now
    sources[name] = data
  end
end
