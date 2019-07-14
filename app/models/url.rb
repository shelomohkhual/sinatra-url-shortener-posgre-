class Url < ActiveRecord::Base
    validates :ori_url, presence: true
    validates_format_of :ori_url, :with => /\A(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?/
  end