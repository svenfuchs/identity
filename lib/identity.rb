require 'simply_stored/couch'
require 'active_support/core_ext/time/conversions' # twitter4r implicitely uses to_formatted_s
require 'active_support/core_ext/hash/keys'        # simply_stored implicitely uses assert_valid_keys
require 'couch_potato_namespace_fix'

class Identity
  autoload :Command,  'identity/command'
  autoload :Message,  'identity/message'
  autoload :Listener, 'identity/listener'
  autoload :Poller,   'identity/poller'
  autoload :Sources,  'identity/sources'

  include SimplyStored::Couch

  # sanitize data ...

  property :profiles
  property :groups

  view :by_handle, :key => :handle, :type => :custom, :map => <<-js
    function(doc) {
      if(doc.ruby_class && doc.ruby_class == 'Identity') {
        for(name in doc['profiles']) {
          if(doc['profiles'][name]['handle']) {
            emit(doc['profiles'][name]['handle'], doc);
          }
        }
      }
    }
  js

  def initialize(profiles = {})
    @profiles = profiles
    @groups = []
  end

  Sources.each_name do |name|
    define_method(name) { profiles[name] || {} }
    define_method(:"#{name}=") { |profile| profiles[name] = profile }
  end

  def claim
    profiles.each { |name, profile| p profile; profile['claimed_at'] = Time.now unless profile['claimed_at'] }
  end

  def set_profile(name, profile)
    claimed_at = send(name)['claimed_at']
    profile.merge!('claimed_at' => claimed_at) if claimed_at
    profiles[name] = profile
  end
end
