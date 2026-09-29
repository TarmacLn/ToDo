class Item < ApplicationRecord
  belongs_to :todo

  validates :name, presence: true
  validates :done, inclusion: { in: [ true, false ] }
end
