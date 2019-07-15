class Url < ActiveRecord::Base
    validates :ori_url, presence: { message: "Nothing to Shortend!" }
    validates :ori_url, format: { with: /\A(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?/, message: "Your URL is Invalid!"}
    # validates :card_number, presence: true, if: :paid_with_card?
    # validates :ori_url, uniqueness: false, if: :existed_url?



    # Person.create.errors[:name].any?
    # Url.create.errors[:ori_url].existed_url?
    # def existed_url?

    # end


  end