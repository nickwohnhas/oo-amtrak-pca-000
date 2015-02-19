class Ticket

  attr_reader :origin, :destination, :ticket_holder

  def initialize(origin, destination, name)
    @origin = origin
    @destination = destination
    @name = name
  end

end