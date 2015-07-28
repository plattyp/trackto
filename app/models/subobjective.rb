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

  def self.subobjective_count_by_user(user)
    count = 0
    user.objectives.each do |o|
      count += o.subobjectives.count
    end
    count
  end

  def last_progress_on
    most_recent_progress || Time.zone.local(1000, 12, 31, 01, 01, 01)
  end

  def has_no_progress_today?
    ((Time.zone.now - last_progress_on).to_i / 1.day) >= 1
  end

  private

  def most_recent_progress
    self.progresses.maximum(:updated_at) if has_progress?
  end

  def has_progress?
    progress > 0
  end
end
