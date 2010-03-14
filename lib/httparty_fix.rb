# HTTParty::Request#uri adds a ? to an uri, thus breaking tinyurl & co

module HTTParty
  class Request #:nodoc:
    def uri
      new_uri = path.relative? ? URI.parse("#{options[:base_uri]}#{path}") : path

      # avoid double query string on redirects [#12]
      unless @redirect
        query = query_string(new_uri)
        new_uri.query = query unless query.nil? || query.empty?
      end

      new_uri
    end
  end
end
