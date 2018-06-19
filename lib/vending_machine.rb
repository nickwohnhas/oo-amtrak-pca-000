require 'json'
class VendingMachine

  attr_reader :stationed_at
  attr_accessor :route

  def initialize(path, location)
    @stationed_at = location
    @path = path
    @tickets = []
    @route = load_json_file(path)
  end

  def load_json_file(path)
    open_file = File.read(path)
    JSON.parse(open_file)

  end

  def tickets
    @tickets
  end

  def purchase_tickets(destination, num_of_tickets, name)
    if south?(route_direction(destination))

      new_route = @route[starting_index..ending_index(destination)]

      new_route.each do |route_hash|
        if route_hash["remaining seats"] >= num_of_tickets
           route_hash["remaining seats"] -= num_of_tickets

        else
          return "Tickets can't be purchased because there are not enough seats. We aplogize for the inconvenience."
        end
      end

   else

      new_route = @route[ending_index(destination)..starting_index].reverse

      new_route.each do |route_hash|
        if route_hash["remaining seats"] >= num_of_tickets
           route_hash["remaining seats"] -= num_of_tickets

        else
          return "Tickets can't be purchased because there are not enough seats. We aplogize for the inconvenience."
        end
      end

    end
     create_ticket(num_of_tickets, destination, name)
     return "Transaction completed, thank you for choosing Amtrak."
   end

  def route_direction(destination)
    empty_array = []
    both = @route.map do | route_hash|
      route_hash.select do |key, value|
        if value == @stationed_at || value == destination
          empty_array << value
        end
      end
    end
    empty_array
  end

  def south?(destination_array)
    destination_array.first == @stationed_at
  end

  def starting_index
    route.each_with_index do |route_hash, index|
      if route_hash["station name"] == @stationed_at
        return index
      end
    end
  end

  def ending_index(destination)
    route.each_with_index do |route_hash, index|
      if route_hash["station name"] == destination
        return index
      end
    end
  end

  def final_destination(index,num_of_tickets)
   if route[index]["remaining seats"] >= num_of_tickets
    route[index]["remaining seats"] -= num_of_tickets


   end
  end

  def create_ticket(num_of_tickets, destination, name)
    num_of_tickets.times do
      ticket = Ticket.new(@stationed_at, destination, name)
    tickets << ticket
    end
  end

end
