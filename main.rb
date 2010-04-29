module Points
  def self.data
    @@data ||= make
  end

  def self.make
    db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://rifgraf.db')
    make_table(db)
    db[:points]
  end

  def self.make_table(db)
    db.create_table :points do
      varchar :graph, :size => 32
      varchar :value, :size => 32
      timestamp :timestamp
    end
  rescue Sequel::DatabaseError
    # assume table already exists
  end
end

# --------------------------------------- Helpers
helpers do
  def graphs_from_params(separator)
    [ params[:id] ] + (params[:and] || '').split(separator)
  end
  
  def collect_data_points
    data = []
    graphs_from_params(',').each do |graph|
      points = Points.data.filter(:graph => graph).reverse_order(:timestamp) 
      data << points.collect { |point| [point[:timestamp].to_i*1000, point[:value].to_f] } if points.count > 0
    end
    data.to_json
  end
end


get '/' do
  graphs = []
  Points.data.group(:graph).select(:graph).each do |row|
    graphs << row[:graph]
  end
  erb :about, :locals => {:graphs => graphs}
end

get '/graphs/:id' do
  erb :graph, :locals => { :data => collect_data_points, :id => params[:id], :others => (params[:and] || '').split(',')}
end

post '/graphs/:id' do
  Points.data << { :graph => params[:id], :timestamp => (params[:timestamp] || Time.now), :value => params[:value] }
  "ok"
end

delete '/graphs/:id' do
  Points.data.filter(:graph => params[:id]).delete
  "ok"
end

get '/graphs/:id/data.json' do
  content_type 'application/json'
  collect_data_points
end
