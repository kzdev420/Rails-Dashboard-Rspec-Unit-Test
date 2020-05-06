module Validators
  class Url < ActiveModel::Validator

    def initialize(*args)
      super
      @attribute = options[:attribute]
    end

    def validate(record)
      unless url_valid?(record.send(@attribute))
        record.errors.add(@attribute, :invalid, error: "URL invalid")
      end
    end

    # a URL may be technically well-formed but may
    # not actually be valid, so this checks for both.
    def url_valid?(url)
      url = URI.parse(url)
      if url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS) || url.kind_of?(URI::Generic)
        begin
          IPAddr.new(url.to_s)
        rescue
          URI.regexp(["http", "https", "rtsp", "rtp"]).match(url.to_s).present?
        end
      end
    rescue
      false
    end
  end
end