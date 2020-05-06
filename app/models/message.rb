##
# Model to handle message created by {Dispute dispute} between admins and users, generally associated to an parking session.
# ## Table's Columns
# - subject => [string] Generally associated to {Dispute dispute model}
# - text => [text] Message body
# - author => [string] Sender of the message can be an {Admin admin} or a {User user}
# - read => [boolean] If the message was read
# - to => [string] Receiver of the message can be an {Admin admin} or a {User user}
# - template => [integer] Reason of the message
# - title => [string] Title automatically set depending on the template
# - parking_session_id => [bigint] ID reference to a parking session
# - created_at => [datetime]
# - updated_at => [datetime]
class Message < ApplicationRecord
  belongs_to :subject, polymorphic: true, optional: true
  belongs_to :author, polymorphic: true, optional: true
  belongs_to :to, polymorphic: true
  belongs_to :parking_session, optional: true

  validates :text, presence: true
  enum template: {
    dispute: 0,
    invoice: 1,
    violation: 2,
    promotion: 3
  }

  before_validation do
    if !title && template
      locales_key = "activerecord.models.message.templates.#{template}_title"
      self.title = I18n.t(locales_key) if I18n.exists?(locales_key)
    end
  end

end
