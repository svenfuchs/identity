class Identity::Message
  class << self
    def if_unprocessed(receiver, message)
      raise 'message.id is nil' unless message.id
      return if find_by_message_id(message.id)
      yield
      create :message_id  => message.id,
             :text        => message.text,
             :sender      => message.user.screen_name,
             :receiver    => receiver,
             :received_at => Time.now
    end

    def max_message_id # TODO how the fuck would i not jump through all of these
      database = CouchPotato.database.instance_variable_get(:@database)
      spec     = Identity::Message.view_max_message_id
      query    = CouchPotato::View::ViewQuery.new(database, spec.design_document, spec.view_name, spec.map_function, spec.reduce_function)
      result   = query.query_view!(spec.view_parameters)['rows'].first
      result['value'] if result
    end
  end

  include SimplyStored::Couch

  # sanitize data ...

  property :message_id
  property :text
  property :sender
  property :receiver
  property :received_at

  view :by_message_id, :key => :message_id
  view :view_max_message_id, :type => :custom,
    :map    => "function(doc) { if(doc.ruby_class == 'Identity::Message') { emit(null, doc['message_id']); } }",
    :reduce => "function(key, values, rereduce) { return Math.max.apply(Math, values); }"

  def initialize(data = {})
    data.each { |key, value| self.send("#{key}=", value) }
  end
end