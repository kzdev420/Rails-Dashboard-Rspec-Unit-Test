# redis = Redis.new(:url => 'redis://hostname:port/db')
# msg = {
#         "class" => 'Ai::QueueWorker',
#         "args" => [ai_payload]
#       }
#
# redis.lpush("queue:ai", JSON.dump(msg))
# redis.sadd("queues", "ai")

module Ai
  class QueueWorker
    include Sidekiq::Worker
    sidekiq_options queue: :ai, retry: false

    def perform(payload)
      result = EventDispatcher.dispatch(payload.with_indifferent_access)
      raise MessageNotProcessedError.new(payload.to_json) unless result
    end

    class MessageNotProcessedError < StandardError
      def initialize(message)
        @message = message
      end

      def message
        "Event #{@message} was not proccessed. It was removed from Queue"
      end
    end
  end
end
