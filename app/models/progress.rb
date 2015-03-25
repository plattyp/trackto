class Progress < ActiveRecord::Base
	belongs_to :objective
	
	validates :amount, numericality: { only_integer: true }
end
