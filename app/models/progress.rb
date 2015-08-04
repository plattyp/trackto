class Progress < ActiveRecord::Base
  belongs_to :progressable, polymorphic: true

  #validates :objective, :presence => true
  validates :amount, numericality: { only_integer: true }

  scope :recent_progress, -> { order('progresses.created_at DESC') }

  def self.progress_history(objective)
    progress = []

    # Pull all progress associated with the subobjectives for that objective
    objective.subobjectives.each do |subobjective|
      subobjective.progresses.recent_progress.each do |p|
        progress << {name: subobjective.name, type: "Subobjective", subobjective_id: p.progressable_id, id: p.id, amount: p.amount, created_at: p.created_at.to_s, created_at_date: p.created_at}
      end
    end

    return progress.sort_by {|p| p[:created_at_date]}.reverse
  end

  def self.progress_overview_by_user_by_timeframe(userId, timeframe, limit, offsetseconds)
    query = ""
    if timeframe === 'days'
      query = "SELECT 
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD') AS x,
              sum(p.amount) AS progress
              FROM progresses p
              join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
              join objectives o on s.objective_id = o.id
              WHERE
              (p.created_at + interval '"+ offsetseconds.to_s + " seconds') > (current_date - interval '" + limit.to_s + " days')
              AND o.user_id = " + userId.to_s + "
              GROUP BY
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')
              ORDER BY
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')"
    end

    if !query.blank?
      mappedresults = {}
      results = ActiveRecord::Base.connection.execute(query)
      results.each do |r|
        mappedresults[r['x']] = r['progress']
      end
      return mappedresults
    end

    return {}
  end

  def self.progress_overview_by_subobjective_by_timeframe(userId, objectiveId, timeframe, limit, offsetseconds)
    query = ""
    if timeframe === 'days'
      query = "SELECT 
              s.id AS subobjective_id,
              s.name AS subobjective,
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD') AS x,
              sum(p.amount) AS progress
              FROM progresses p
              join subobjectives s on p.progressable_id = s.id and p.progressable_type = 'Subobjective'
              join objectives o on s.objective_id = o.id
              WHERE
              (p.created_at + interval '"+ offsetseconds.to_s + " seconds') > (current_date - interval '" + limit.to_s + " days')
              AND o.user_id = " + userId.to_s + "
              AND o.id = " + objectiveId.to_s + "
              GROUP BY
              s.id,
              s.name,
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')
              ORDER BY
              s.id,
              to_char(p.created_at + interval '"+ offsetseconds.to_s + " seconds','YYYY-MM-DD')"
    end

    if !query.blank?
      mappedresults = {}
      results = ActiveRecord::Base.connection.execute(query)
      results.group_by{|s| s['subobjective']}.each do |k,v|
        values = {}
        v.each do |p|
          values[p['x']] = p['progress']
        end
        mappedresults[k] = values
      end
      return mappedresults
    end

    return {}
  end
  
  def self.all_progress
    progress = []
    Progress.all.each do |p|
        progress << {id: p.id, amount: p.amount, type: "Subobjective", subobjective_id: p.progressable_id, updated_at: p.updated_at.to_s}
    end
    progress
  end

end
