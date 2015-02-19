require_relative '../lib/ticket.rb'
require_relative '../lib/vending_machine.rb'

require 'pry'

RSpec.configure do |config|

end

def fetch_involved_stations(route, origin, destination)
  indexes = get_origin_and_destination_indexes(route, origin, destination)
  o_i = indexes[:origin]
  d_i = indexes[:destination]
  o_i, d_i = d_i, o_i if o_i > d_i
  stations = {}
  route[o_i..d_i].each.with_index(o_i) do |station, i|
    stations[station["station name"]] = i
  end
  stations
end

def get_origin_and_destination_indexes(route, origin, destination)
  indexes = {}
  route.each_with_index do |station, i|
    indexes[:origin] = i if station["station name"] == origin
    indexes[:destination] = i if station["station name"] == destination
  end
  indexes
end