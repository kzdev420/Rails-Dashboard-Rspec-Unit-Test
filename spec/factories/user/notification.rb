FactoryBot.define do
  factory :user_notification, class: User::Notification do
    text { Faker::Lorem.paragraph }
    title do
      locales_key = "activerecord.models.user/notification.templates.#{User::Notification.templates.keys.sample}_title"
      I18n.t(locales_key)
    end
    user
    parking_session
  end
end
