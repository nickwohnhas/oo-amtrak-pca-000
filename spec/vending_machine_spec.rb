describe "VendingMachine" do

  let(:acela_file)     { "spec/fixtures/acela_express_train.json" }
  let(:surfliner_file) { "spec/fixtures/pacific_surfliner.json"   }
  let(:acela)          { JSON.parse(File.read(acela_file))        } 
  let(:surfliner)      { JSON.parse(File.read(surfliner_file))    }

  describe "#initialize" do
    it "accepts one argument, a path to a JSON file" do
      expect { VendingMachine.new(acela_file) }.to_not raise_error
    end
  end

  let(:acela_machine) { VendingMachine.new(acela_file) }
  let(:surf_machine) { VendingMachine.new(surfliner_file) }
  let(:machines)  { [acela_machine, surf_machine] }
  let(:thank_you) { "Transaction completed, thank you for choosing Amtrak." }
  let(:sorry) { "Tickets can't be purchased because there are not enough seats. We aplogize for the inconvenience." }

  describe "#load_json_file" do
    
    it "accepts a file path as an argument" do
      expect { acela_machine.load_json_file(acela_file) }.to_not raise_error
    end

    it "reads and parses a json file and returns the resulting array or hash" do
      expect(acela_machine.load_json_file(acela_file)).to eq(acela)
      expect(surf_machine.load_json_file(surfliner_file)).to eq(surfliner)
    end

  end

  describe "#tickets" do
    it "initializes with an empty tickets array" do
       machines.each do |vending_machine|
        expect(vending_machine.tickets.class).to eq(Array)
        expect(vending_machine.tickets.empty?).to eq(true)
      end
    end
  end

  describe "#tickets=" do
    it "can change its tickets" do
      ticket = Ticket.new("Boston", "New York", "Harold Cooper")
      expect { acela_machine.tickets  << ticket }.to_not raise_error
      num_of_tickets = acela_machine.tickets.length
      acela_machine.tickets  << ticket
      expect(acela_machine.tickets.length).to eq(num_of_tickets + 1)
    end
  end

  describe "#route (on initialize)" do
    it "calls on #load_json_file and passes it the file path, sets the return value equal to 'route'" do
      result = acela_machine.load_json_file(acela_file)
      expect_any_instance_of(VendingMachine).to receive(:load_json_file).with(acela_file).and_return(result)
      VendingMachine.new(acela_file)
    end
    it "knows about its route" do
      expect(acela_machine.route).to eq(acela)
    end
  end

  describe "#route=" do
    it "can be changed" do
      expect { acela_machine.route = surfliner }.to_not raise_error
      seats_left = acela_machine.route[0]["remaining seats"]
      acela_machine.route[0]["remaining seats"] += 2
      expect(acela_machine.route[0]["remaining seats"]).to eq(seats_left + 2)
    end
  end

  describe "#purchase_tickets" do
    it "accepts four arguments, the origin, destination, number of tickets, and purchaser's name" do
      expect { acela_machine.purchase_tickets("Providence, RI", "Wilmington, DE", 1, "Javier O'Hara") } 
    end

    let(:enough_seats) { acela_machine.purchase_tickets("Providence, RI", "Wilmington, DE", 1, "Javier O'Hara") }

    it "issues a ticket when there are remaining seats and train is headed south" do
      ticket = Ticket.new("Providence, RI", "Wilmington, DE", "Javier O'Hara")
      expect(Ticket).to receive(:new).with("Providence, RI", "Wilmington, DE", "Javier O'Hara").and_return(ticket)
      
      ticket_count = acela_machine.tickets.length
      acela_machine.purchase_tickets("Providence, RI", "Wilmington, DE", 1, "Javier O'Hara")
      expect(acela_machine.tickets.length).to eq(ticket_count + 1)
      expect(acela_machine.tickets).to include(ticket)
    end

    it "issues a ticket when there are remaining seats and train is headed north" do
      ticket = Ticket.new( "Wilmington, DE", "Providence, RI", "Javier O'Hara")
      expect(Ticket).to receive(:new).with("Wilmington, DE", "Providence, RI", "Javier O'Hara").and_return(ticket)
      
      ticket_count = acela_machine.tickets.length
      acela_machine.purchase_tickets("Wilmington, DE", "Providence, RI", 1, "Javier O'Hara")
      expect(acela_machine.tickets.length).to eq(ticket_count + 1)
      expect(acela_machine.tickets).to include(ticket)
    end

    it "thanks the customer for purchasing tickets" do
      expect(enough_seats).to eq(thank_you)
    end

    it "can purchase multiple tickets" do
      ticket = Ticket.new("Stamford, CT", "Providence, RI", "Blake Lowell")
      expect(Ticket).to receive(:new).exactly(3).times.with("Stamford, CT", "Providence, RI", "Blake Lowell").and_return(ticket)
      ticket_count = acela_machine.tickets.length
      acela_machine.purchase_tickets("Stamford, CT", "Providence, RI", 3, "Blake Lowell")
      expect(acela_machine.tickets.length).to eq(ticket_count + 3)
    end

    it "reduces the number of seats left by the number of tickets issued when train is headed south" do
      ticket = Ticket.new("Stamford, CT", "Providence, RI", "Blake Lowell")
      expect(Ticket).to receive(:new).exactly(3).times.with("Stamford, CT", "Providence, RI", "Blake Lowell").and_return(ticket)
      
      acela_machine.purchase_tickets("Stamford, CT", "Providence, RI", 3, "Blake Lowell")
      stations = fetch_involved_stations(acela, "Stamford, CT", "Providence, RI")
      stations.each do |station_name, i|
        original = acela[i]["remaining seats"]
        expect(acela_machine.route[i]["remaining seats"]).to eq(original - 3)
      end
    end

    it "reduces the number of seats left by the number of tickets issued when train is headed north" do
      ticket = Ticket.new("Stamford, CT", "Providence, RI", "Blake Lowell")
      expect(Ticket).to receive(:new).exactly(2).times.with("Stamford, CT", "Providence, RI", "Blake Lowell").and_return(ticket)
      
      acela_machine.purchase_tickets("Stamford, CT", "Providence, RI", 2, "Blake Lowell")
      stations = fetch_involved_stations(acela, "Stamford, CT", "Providence, RI")
      stations.each do |station_name, i|
        original = acela[i]["remaining seats"]
        expect(acela_machine.route[i]["remaining seats"]).to eq(original - 2)
      end
    end

    let(:not_enough_seats_middle) { surf_machine.purchase_tickets("Surf, CA", "Ventura, CA", 1, "Amy Poehler") }
    let(:not_enough_seats_begin) { surf_machine.purchase_tickets("Santa Barbara, CA", "Fullerton, CA", 1, "Chelsea Peretti") }
    let(:not_enough_seats_end) { surf_machine.purchase_tickets("San Luis Obispo, CA", "Carpinteria, CA", 1, "Sarah Silverman") }
    let(:passenger_exits_after_train_fills_up) { surf_machine.purchase_tickets("Grover Beach, CA", "Santa Barbara, CA", 1, "Zach Galifianakis") }
    
    it "apologizes because of a full train in middle of ride and doesn't buy tickets" do
      ticket_count = surf_machine.tickets.length
      expect(Ticket).to_not receive(:new)      
      expect(not_enough_seats_middle).to eq(sorry)
      expect(surf_machine.tickets.length).to eq(ticket_count)
    end

    it "apologizes because of a full train in beginning of ride and doesn't buy tickets" do
      ticket_count = surf_machine.tickets.length
      expect(Ticket).to_not receive(:new)      
      expect(not_enough_seats_begin).to eq(sorry)
      expect(surf_machine.tickets.length).to eq(ticket_count)
    end

    it "apologizes because of a full train at end of ride and doesn't buy tickets" do
      ticket_count = surf_machine.tickets.length
      expect(Ticket).to_not receive(:new)      
      expect(not_enough_seats_end).to eq(sorry)
      expect(surf_machine.tickets.length).to eq(ticket_count)
    end

    it "purchases tickets when the train doesn't get full until after the passenger gets off" do
      ticket_count = surf_machine.tickets.length
      ticket = Ticket.new("Grover Beach, CA", "Santa Barbara, CA", "Zach Galifianakis")
      expect(Ticket).to receive(:new).with("Grover Beach, CA", "Santa Barbara, CA", "Zach Galifianakis").once.and_return(ticket)     
      expect(passenger_exits_after_train_fills_up).to eq(thank_you)
      expect(surf_machine.tickets.length).to eq(ticket_count + 1)
      expect(surf_machine.tickets).to include(ticket)
    end

  end

end