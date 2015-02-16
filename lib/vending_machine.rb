def VendingMachine

  attr_accessor :tickets, :route

  def initialize(data_file_path)
    @route =load_json_file(data_file_path)
    @tickets = []
  end

  def load_json_file(file_path)
    JSON.load(File.read(file_path))
  end

  def find_trip_indexes(origin, destination)
    route.each_with_index do |station, i| 
      o_i = i if station["station name"] == origin
      d_i = i if station["station name"] == destination
    end
    [o_i, d_i]
  end

  def tickets_available?(origin_index, destination_index, num_of_tickets)
    route[origin_index..destination_index].each do |station|
      return false if station["remaining seats"] < num_of_tickets
    end
    true
  end

  def get_price(origin_index, destination_index)
    (destination_index - origin_index + 1) * 10
  end

  def purchase_tickets(origin, destination, num_of_tickets, name)
    origin_index, destination_index = find_trip_indexes(origin, destination)
    if destination_index < origin_index
       origin_index, destination_index = destination_index, origin_index
    end
    if tickets_available?(origin_index, destination_index, num_of_tickets)
      price = get_price(origin_index, destination_index)
      num_of_tickets.times do
        self.tickets << Ticket.new(origin, destination, name, price)
      end
      adjust_num_of_remaining_seats(origin_index, destination_index, num_of_tickets)
    end
  end

  def adjust_num_of_remaining_seats(origin_index, destination_index, num_of_tickets)
    self.route[origin_index..destination_index].each do |station|
      station["remaining seats"] -= num_of_tickets
    end
  end

end