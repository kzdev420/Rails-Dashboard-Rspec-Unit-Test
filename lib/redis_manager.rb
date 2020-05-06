class RedisManager
  def initialize(options = {})
    @options = options
  end

  def ai_queue
    @ai_queue ||= Redis.new(@options.merge(db: 0))
  end

  def ai_state
    @ai_state ||= Redis.new(@options.merge(db: 1))
  end

  def watching_camera
    @watching_camera ||= Redis.new(@options.merge(db: 2))
  end

  def flushall
    ai_queue.flushdb
    ai_state.flushdb
    watching_camera.flushdb
  end
end
