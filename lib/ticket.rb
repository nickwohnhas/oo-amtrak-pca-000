require 'json'

class Ticket
  attr_accessor :origin, :destination, :name

  def initialize(origin, destination, name)
    @name = name
    @origin = origin
    @destination = destination
  end

end
