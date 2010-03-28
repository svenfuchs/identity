require 'simply_stored/couch'
require 'active_support/core_ext/time/conversions' # twitter4r implicitely uses to_formatted_s
require 'active_support/core_ext/hash/keys'        # simply_stored implicitely uses assert_valid_keys
require 'couch_potato_namespace_fix'

class Identity
  autoload :Command,  'identity/command'
  autoload :Helpers,  'identity/helpers'
  autoload :Sources,  'identity/sources'

  include SimplyStored::Couch

  # TODO gotta sanitize data ...

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
    self.profiles = profiles
  end

  Sources.each_name do |name|
    define_method(name) { profiles[name] || {} }
    define_method(:"#{name}=") { |profile| profiles[name] = profile }
  end

  def handles
    @handles ||= profiles.map { |name, profile| profile['handle'] }.compact.uniq
  end
  
  def avatar
    @avatar ||= begin
      profiles['twitter'] && "http://headhunter.heroku.com/#{profiles['twitter']['handle']}" ||
      profiles.map { |name, profile| profile['avatar'] }.compact.first
    end
  end

  def url
    @url ||= profiles.map { |name, profile| profile['url'] }.compact.first
  end

  def name
    @name ||= profiles.map { |name, profile| profile['name'] }.compact.first
  end

  def claim
    profiles.each { |name, profile| profile['claimed_at'] = Time.now unless profile['claimed_at'] }
  end

  def set_profile(name, profile)
    claimed_at = send(name)['claimed_at']
    profile.merge!('claimed_at' => claimed_at) if claimed_at
    profiles[name] = profile
  end

  def to_json(*args)
    { :handles => handles, :profiles => profiles, :groups => groups, :created_at => created_at }.to_json
  end
end

class Command
  include Identity::Command
end