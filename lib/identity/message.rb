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
  end
  
  include SimplyStored::Couch

  # sanitize data ...

  property :message_id
  property :text
  property :sender
  property :receiver
  property :received_at
  
  view :by_message_id, :key => :message_id

  def initialize(data = {})
    data.each { |key, value| self.send("#{key}=", value) }
  end
end