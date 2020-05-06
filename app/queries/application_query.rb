class ApplicationQuery
  attr_reader :page, :per_page, :options

  def initialize(options = {})
    @per_page ||= options[:per_page] || 20
    @page ||= options[:page] || 1
    @options = options
  end

  def self.call(*args)
    new(*args).call
  end
end
