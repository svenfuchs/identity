class Command::Message
  class << self
    def if_unprocessed(data)
      return if find_by_message_id(data[:message_id])
      yield create(data.merge(:received_at => Time.now))
    end

    def max_message_id # TODO how the fuck would i not jump through all of these hoops
      database = CouchPotato.database.instance_variable_get(:@database)
      spec     = view_max_message_id
      query    = CouchPotato::View::ViewQuery.new(database, spec.design_document, spec.view_name, spec.map_function, spec.reduce_function)
      result   = query.query_view!(spec.view_parameters)['rows'].first
      result['value'] if result
    end
  end
  
  COMMAND_PATTERN  = /(?:!|#)([\w]+)/
  ARGUMENT_PATTERN = /[\S]+:[\S]+/

  include SimplyStored::Couch

  property :message_id
  property :text
  property :sender
  property :receiver
  property :source
  property :received_at

  view :by_message_id, :key => :message_id
  view :view_max_message_id, :type => :custom,
    :map    => "function(doc) { if(doc.ruby_class == 'Command::Message') { emit(null, doc['message_id']); } }",
    :reduce => "function(key, values, rereduce) { return Math.max.apply(Math, values); }"

  def initialize(data = {})
    data.each { |key, value| self.send("#{key}=", value) }
  end
  
  def commands
    text.scan(COMMAND_PATTERN).flatten
  end

  def arguments
    text.scan(ARGUMENT_PATTERN)
  end
end