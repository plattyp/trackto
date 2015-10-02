require 'time'

class Subobjective < ActiveRecord::Base
  belongs_to :objective
  delegate :user, :to => :objective, :allow_nil => true
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

  def has_no_progress_today?(offset)
    now_offset = Time.now.utc + offset
    last_prog_offset = last_progress_on + offset
    now_offset.strftime("%m/%d/%Y") != last_prog_offset.strftime("%m/%d/%Y")
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

  def get_current_subobjective_streak(offsetseconds)
    query = "
            WITH streak_data AS (
              SELECT
                sub_id,
                date::date AS date,
                grp,
                row_number() OVER (PARTITION BY sub_id, grp ORDER BY date) AS streak
              FROM
                (
                  SELECT
                    sub_id,
                    date,
                    date::date - '2000-01-01'::date - row_number() OVER (ORDER BY sub_id, date) as grp
                    FROM
                  (
                  SELECT
                    s.id AS sub_id,
                    to_char((p.created_at + interval '" + offsetseconds.to_s + " seconds'),'YYYY-MM-DD') AS date,
                    sum(p.amount) AS progress
                  FROM 
                    progresses p
                    join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
                    join objectives o on s.objective_id = o.id
                  WHERE
                    s.id = " + id.to_s + "
                  GROUP BY
                    s.id,
                    to_char((p.created_at + interval '" + offsetseconds.to_s + " seconds'),'YYYY-MM-DD')
                  ) t 
                ) s
            )
            SELECT
              sub_id,
              max(streak) streak,
              min(date) begin_date,
              max(date) end_date
            FROM
              streak_data
            WHERE
              grp = 
            (
              SELECT
                max(grp)
              FROM
                streak_data
              WHERE
                date = (now() + interval '" + offsetseconds.to_s + " seconds')::date
                AND streak = 
                (
                SELECT
                  max(streak)
                FROM
                  streak_data
                WHERE
                  date = (now() + interval '" + offsetseconds.to_s + " seconds')::date
                )
            )
            GROUP BY
              sub_id"

    results = ActiveRecord::Base.connection.execute(query)
    mapped = {}
    if results.any?
      # Find more info on subobjective
      sub_id = results[0]['sub_id']
      sub = Subobjective.find(sub_id)
      
      mapped[:subobjective_id]   = sub_id
      mapped[:subobjective_name] = sub.name
      mapped[:streak]            = results[0]['streak']
      mapped[:begin_date]        = results[0]['begin_date']
      mapped[:end_date]          = results[0]['end_date']
    else
      mapped[:subobjective_id]   = -1
      mapped[:streak]            = 0
    end

    return mapped
  end

  private

  def most_recent_progress
    self.progresses.maximum(:updated_at) if has_progress?
  end

  def has_progress?
    progress > 0
  end
end
