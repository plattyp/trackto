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
    query = ""
    if daylimit > 0
      query = "SELECT
              MAX(streak) AS streak
              FROM
              (
              SELECT
              date,
              grp,
              row_number() OVER (PARTITION BY grp ORDER BY date) AS streak
              FROM
              (
              SELECT
              date,
              date::date - '2000-01-01'::date - row_number() OVER (ORDER BY date) as grp
              FROM
              (
              SELECT 
              to_char(p.created_at,'YYYY-MM-DD') AS date,
              sum(p.amount) AS progress
              FROM 
                progresses p
                join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
                join objectives o on s.objective_id = o.id
              WHERE
                s.id = " + id.to_s + "
                AND p.created_at > (current_date - interval '" + daylimit.to_s + " days')
              GROUP BY
                to_char(p.created_at,'YYYY-MM-DD')
              ) t ) s ) o"
    end

    streak = 0
    if !query.blank?
      results = ActiveRecord::Base.connection.execute(query)
      streak = results[0]['streak'] || 0
    end

    return streak
  end

  private

  def most_recent_progress
    self.progresses.maximum(:updated_at) if has_progress?
  end

  def has_progress?
    progress > 0
  end
end
