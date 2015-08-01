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

  def get_streak_in_last_days(daylimit)
    sorted = self.progresses.sort { |x, y| x.created_at <=> y.created_at }

    streak = 0
    previousvalue = -1
    sorted.each do |s|
      daysago = (Time.zone.now - s.created_at).to_i / 1.day
      # Ensure the day value is within the limit set
      if daysago < daylimit
        # Ensure I only compare after the first iteration
        if previousvalue > -1
          # Compare value and determine if the previous progress happened the day before
          if daysago === (previousvalue - 1)
            streak += 1
          # Compare value and determine if the previous progress happened the same day
          elsif daysago === previousvalue
            streak = streak
          # If neither, reset the streak
          else
            streak = 0
          end
        end
        # Set the previous value to the current day for comparison
        previousvalue = daysago
      end
    end

    # If there has been any progress within limit, show 1 as the streak
    if previousvalue > -1 && streak === 0
      return 1
    else 
      return streak
    end
  end

  private

  def most_recent_progress
    self.progresses.maximum(:updated_at) if has_progress?
  end

  def has_progress?
    progress > 0
  end
end
