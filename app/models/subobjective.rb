class Subobjective < ActiveRecord::Base
  belongs_to :objective
  has_many :progresses, as: :progressable, :dependent => :destroy

  def self.all_subobjectives(objective)
    subobjectives = []
    objective.subobjectives.each do |p|
      subobjectives << {name: p.id, description: p.description, created_at: p.created_at.to_s}
    end
    subobjectives
  end

  def progress
    amount = 0
    self.progresses.each { |p| amount += p.amount }
    amount
  end
end
