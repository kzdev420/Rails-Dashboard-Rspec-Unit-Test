##
# Model to handle multiple images that another model could have
class Image < ApplicationRecord
  include ActiveStorageSupport::SupportForBase64
  belongs_to :imageable, polymorphic: true
  has_one_base64_attached :file
  validates :file, presence: true
end
