class Ticket

  attr_reader :origin, :destination, :name

  def initialize(origin, destination, name)
    @origin = origin
    @destination = destination
    @name = name
  end

end