options = {
  host: ENV['REDIS_HOST'],
  port: ENV['REDIS_PORT']
}
options.merge!(password: ENV['REDIS_PASSWORD']) if ENV['REDIS_PASSWORD'].present?

$redis_manager = RedisManager.new(options)
