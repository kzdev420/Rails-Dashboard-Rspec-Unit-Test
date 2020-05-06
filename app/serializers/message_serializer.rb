class MessageSerializer < ApplicationSerializer
  attributes :id, :text

  attribute :created_at do
    utc(object.created_at)
  end

  attribute :author do
    object.author.as_json(only: [:id, :email])
  end
end
