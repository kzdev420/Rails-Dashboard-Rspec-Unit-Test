class FootageWatchersChannel < ApplicationCable::Channel
  include Rails.application.routes.url_helpers

  before_subscribe :load_data
  before_unsubscribe :load_data

  after_subscribe :broadcast
  after_unsubscribe :broadcast

  def subscribed
    add_current_watcher_id
    stream_from "camera_channel_#{@camera.id}"
  end

  def unsubscribed
    remove_current_watcher_id
  end

  def watchers
    @camera = Camera.find(params[:camera_id])
    data = $redis_manager.watching_camera.get(@camera.cache_key)
    @current_watchers = JSON.parse(data)['admins']
    broadcast
  end

  private

  def load_data
    @camera = Camera.find(params[:camera_id])
    @current_admin = Admin.find(params[:current_user_id])
    data = $redis_manager.watching_camera.get(@camera.cache_key) || { admins: [] }.to_json
    @current_watchers = JSON.parse(data)['admins']
  end

  def remove_current_watcher_id
    save_data do
      @current_watchers.reject! { |admin| admin['id'] == @current_admin.id  }
    end
  end

  def add_current_watcher_id
    save_data do
      avatar = url_for(@current_admin.avatar) if @current_admin.avatar.attached?
      @current_watchers.push( { id: @current_admin.id, name: @current_admin.name, avatar: avatar }) unless @current_watchers.any? { |h| h['id'] == @current_admin.id }
    end
  end

  def save_data
    yield
    $redis_manager.watching_camera.set(@camera.cache_key, { admins: @current_watchers }.to_json)
  rescue => exc
    Raven.capture_exception(exc)
  end

  def broadcast
    ActionCable.server.broadcast("camera_channel_#{@camera.id}", @current_watchers)
  end

end
