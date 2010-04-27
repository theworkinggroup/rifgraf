require 'sinatra'
require 'sequel'
require 'json'

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

helpers do
  def graphs_from_params(separator)
    [ params[:id] ] + (params[:and] || '').split(separator)
  end
end

get '/' do
  erb :about
end

get '/graphs/:id' do
  graphs_from_params(',').each do |graph|
    throw :halt, [ 404, "No such graph \"#{graph}\"" ] unless Points.data.filter(:graph => graph).count > 0
  end
  
  data = []
  graphs_from_params(',').each do |graph|
    points = Points.data.filter(:graph => graph).reverse_order(:timestamp) 
    data << points.collect { |point| [point[:timestamp].to_i, point[:value].to_f] }
  end
  
  erb :graph, :locals => { :data => data, :id => params[:id], :others => (params[:and] || '').split(',')}
end

post '/graphs/:id' do
  Points.data << { :graph => params[:id], :timestamp => (params[:timestamp] || Time.now), :value => params[:value] }
  "ok"
end

delete '/graphs/:id' do
  Points.data.filter(:graph => params[:id]).delete
  "ok"
end
