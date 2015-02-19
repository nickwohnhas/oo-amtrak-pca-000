require 'json'

class VendingMachine

  attr_accessor :tickets, :route

  def initialize(data_file_path)
    @route = load_json_file(data_file_path)
    @tickets = []
  end

  def load_json_file(file_path)
    JSON.load(File.read(file_path))
  end

  def find_index(station_name)
    route.each_with_index do |station, i|
      return i if station["station name"] == station_name
    end
  end

  def seats_available?(origin_index, destination_index, num_of_tickets)
    route[origin_index...destination_index].each do |station|
      return false if station["remaining seats"] < num_of_tickets
    end
    true
  end

  def purchase_tickets(origin, destination, num_of_tickets, name)
    origin_index = find_index(origin)
    destination_index = find_index(destination)
    flipped = false
    if destination_index < origin_index
       origin_index, destination_index = destination_index, origin_index
       flipped = true
    end
    if seats_available?(origin_index, destination_index, num_of_tickets)
      adjust_num_of_remaining_seats(origin_index, destination_index, num_of_tickets)
      origin_index, destination_index = destination_index, origin_index if flipped
      get_tickets(origin, destination, name, num_of_tickets)
      "Transaction completed, thank you for choosing Amtrak."
    else
      "Tickets can't be purchased because there are not enough seats. We aplogize for the inconvenience."
    end
  end

  def adjust_num_of_remaining_seats(origin_index, destination_index, num_of_tickets)
    self.route.each_with_index do |station, i|
      if origin_index <= i && i <= destination_index
        station["remaining seats"] -= num_of_tickets
      end
    end
  end

  def get_tickets(origin, destination, name, num_of_tickets)
    num_of_tickets.times do
      self.tickets << Ticket.new(origin, destination, name)
    end
  end

end