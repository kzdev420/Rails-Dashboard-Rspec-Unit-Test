class ApplicationController < ActionController::Base

  before_action :set_raven_context

  private

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def append_info_to_payload(payload)
    super
    payload[:body_response] = response.media_type == 'application/json' ? response.body : response.media_type
  end
end
