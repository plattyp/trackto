class Objective < ActiveRecord::Base
  belongs_to :user
  has_many :subobjectives, :dependent => :destroy
  accepts_nested_attributes_for :subobjectives

  validates :name, length: { in: 1..250 }
  validates :description, length: { maximum: 500 }
  validates :progress, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}

  scope :recent_objectives, -> { order('objectives.created_at DESC') }

  def self.objectives_with_progress(user)
    objectives = []
    user.objectives.recent_objectives.each do |p|
      objectives << {id: p.id, name: p.name, description: p.description, progress: p.obj_progress, archived: p.is_archived?, created_at: p.created_at.to_s, updated_at: p.updated_at.to_s}
    end
    objectives
  end

  def self.get_all_subobjectives_not_progressed_today(user)
    subobjectives = []
    user.objectives.each do |o|
      o.subobjectives.each do |s|
        if s.has_no_progress_today?
          subobjectives << {id: s.id, name: s.name, description: s.description, objective_id: o.id, objective_name: o.name}
        end
      end
    end
    subobjectives
  end

  def get_details(offsetseconds)
    obj = self
    {
      id: obj.id,
      name: obj.name,
      description: obj.description,
      subobjective_count: obj.get_subobjective_count,
      obj_progress: obj.obj_progress,
      sub_progress: obj.get_subobjectives_total_progress,
      archived: obj.is_archived?,
      longest_streak: obj.get_longest_subobjective_streak_all_time_with_metadata(offsetseconds),
      current_streak: obj.get_current_subobjective_streak(offsetseconds),
      created_at: obj.created_at,
      updated_at: obj.updated_at
    }
  end

  def get_subobjectives
    subobjectives = []
    self.subobjectives.each do |p|
      subobjectives << {id: p.id, name: p.name, description: p.description, progress: p.progress, created_at: p.created_at.to_s}
    end
    subobjectives
  end

  def get_subobjective_count
    self.subobjectives.size
  end

  def get_subobjectives_total_progress
    total = 0
    self.subobjectives.each do |p|
      total += p.progress
    end
    total
  end

  def get_longest_subobjective_streak_all_time_with_metadata(offsetseconds)
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
                    o.id = " + id.to_s + "
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
                MAX(grp) grp
              FROM
                streak_data
              WHERE
                streak =
                (
                  SELECT
                    MAX(streak) streak
                  FROM
                    streak_data
                )
              )
            GROUP BY
            sub_id"

    results = ActiveRecord::Base.connection.execute(query)
    mapped = {}
    if !results.nil?
      # Find more info on subobjective
      sub_id = results[0]['sub_id']
      sub = Subobjective.find(sub_id)
      
      mapped[:subobjective_id]   = sub_id
      mapped[:subobjective_name] = sub.name
      mapped[:streak]            = results[0]['streak']
      mapped[:begin_date]        = results[0]['begin_date']
      mapped[:end_date]          = results[0]['end_date']
    end

    return mapped
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
                    o.id = " + id.to_s + "
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
      mapped[:streak]            = 0
    end

    return mapped
  end

  def is_archived?
    archived || false
  end

  def obj_progress
    has_progress? ? progress : 0
  end

  def self.objective_count_by_user(user)
    user.objectives.count
  end

  def self.total_progress_per_user(user)
    progress = 0
    user.objectives.each do |o|
      o.subobjectives.each do |s|
        progress += s.progress
      end
    end
    progress
  end

  private

  def has_progress?
    if progress
      progress > 0 ? true : false
    end
  end

end
