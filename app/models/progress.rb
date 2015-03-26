class Progress < ActiveRecord::Base
	belongs_to :objective

	validates :objective, :presence => true
	validates :amount, numericality: { only_integer: true }
end
