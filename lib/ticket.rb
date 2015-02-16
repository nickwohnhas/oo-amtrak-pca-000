class Ticket

  attr_reader :origin, :destination, :ticket_holder, :price

  def initialize(origin, destination, name, price)
    @origin = origin
    @destination = destination
    @price = price
    @name = name
  end

end