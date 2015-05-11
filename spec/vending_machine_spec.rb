describe "VendingMachine" do

  let(:acela_file)     { "spec/fixtures/acela_express_train.json" }
  let(:surfliner_file) { "spec/fixtures/pacific_surfliner.json"   }
  let(:acela)          { JSON.parse(File.read(acela_file))        } 
  let(:surfliner)      { JSON.parse(File.read(surfliner_file))    }

  describe ".new" do
    it "accepts two arguments, a path to the route JSON file and location" do
      expect { VendingMachine.new(acela_file, "New Haven, CT") }.to_not raise_error
    end

    it "saves the second argument as @stationed_at" do
      location = "New Haven, CT"
      vending_machine = VendingMachine.new(acela_file, location)
      expect(vending_machine.instance_eval("@stationed_at")).to eq(location)
      
      new_location = "Grover Beach, CA"
      new_vending_machine = VendingMachine.new(surfliner_file, new_location)
      expect(new_vending_machine.instance_eval("@stationed_at")).to eq(new_location)
    end
  end

  let(:thank_you) { "Transaction completed, thank you for choosing Amtrak." }
  let(:sorry) { "Tickets can't be purchased because there are not enough seats. We aplogize for the inconvenience." }

  let(:acela_machine)  { VendingMachine.new(acela_file, "New Haven, CT") }
  let(:surf_machine)   { VendingMachine.new(surfliner_file, "Grover Beach, CA") }
  let(:machines)       { [acela_machine, surf_machine] }

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

  describe "#stationed_at" do
    it "knows where its stationed" do
      expect(acela_machine.stationed_at).to eq("New Haven, CT")
      expect(surf_machine.stationed_at).to eq("Grover Beach, CA")
    end
    it "can't change its location" do
      machines.each do |machine|
        expect { machine.stationed_at = "Miami, FL"}.to raise_error
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
      VendingMachine.new(acela_file, "New Haven, CT")
    end
    it "knows about its route" do
      expect(acela_machine.route).to eq(acela)
      expect(surf_machine.route).to eq(surfliner)
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
    let(:providence_vm) { VendingMachine.new(acela_file, "Providence, RI") }
    let(:wilmington_vm) { VendingMachine.new(acela_file, "Wilmington, DE") }
    let(:stamford_vm)   { VendingMachine.new(acela_file, "Stamford, CT")   }
    let(:surf_vm)       { VendingMachine.new(surfliner_file, "Surf, CA")   }

    it "accepts 3 arguments: destination, number of tickets, and purchaser's name" do
      expect { providence_vm.purchase_tickets("Wilmington, DE", 1, "Javier O'Hara") }.to_not raise_error 
    end

    let(:not_enough_seats) { surf_vm.purchase_tickets("Ventura, CA", 1, "Javier O'Hara") }
    let(:enough_seats) { providence_vm.purchase_tickets("Wilmington, DE", 1, "Javier O'Hara") }

    it "issues a ticket when there are remaining seats and customer is headed south" do
      ticket = Ticket.new("Providence, RI", "Wilmington, DE", "Javier O'Hara")
      expect(Ticket).to receive(:new).with("Providence, RI", "Wilmington, DE", "Javier O'Hara").and_return(ticket)
      
      ticket_count = providence_vm.tickets.length
      providence_vm.purchase_tickets("Wilmington, DE", 1, "Javier O'Hara")
      expect(providence_vm.tickets.length).to eq(ticket_count + 1)
      expect(providence_vm.tickets).to include(ticket)
    end

    it "issues a ticket when there are remaining seats and customer is headed north" do
      ticket = Ticket.new("Wilmington, DE", "Providence, RI", "Javier O'Hara")
      expect(Ticket).to receive(:new).with("Wilmington, DE", "Providence, RI", "Javier O'Hara").and_return(ticket)
      
      ticket_count = wilmington_vm.tickets.length
      wilmington_vm.purchase_tickets("Providence, RI", 1, "Javier O'Hara")
      expect(wilmington_vm.tickets.length).to eq(ticket_count + 1)
      expect(wilmington_vm.tickets).to include(ticket)
    end

    it "thanks the customer for purchasing tickets" do
      expect(enough_seats).to eq(thank_you)
    end

    it "can purchase multiple tickets" do
      ticket = Ticket.new("Stamford, CT", "Providence, RI", "Blake Lowell")
      expect(Ticket).to receive(:new).exactly(3).times.with("Stamford, CT", "Providence, RI", "Blake Lowell").and_return(ticket)
      ticket_count = stamford_vm.tickets.length
      
      stamford_vm.purchase_tickets("Providence, RI", 3, "Blake Lowell")
      expect(stamford_vm.tickets.length).to eq(ticket_count + 3)
    end

    it "reduces the number of seats left by the number of tickets issued when customer is headed north" do
      ticket = Ticket.new("Stamford, CT", "Providence, RI", "Blake Lowell")
      expect(Ticket).to receive(:new).exactly(3).times.with("Stamford, CT", "Providence, RI", "Blake Lowell").and_return(ticket)
      
      stamford_vm.purchase_tickets("Providence, RI", 3, "Blake Lowell")
      stations = fetch_involved_stations(acela, "Stamford, CT", "Providence, RI")
      stations.each do |station_name, i|
        original = acela[i]["remaining seats"]
        expect(stamford_vm.route[i]["remaining seats"]).to eq(original - 3)
      end
    end

    it "reduces the number of seats left by the number of tickets issued when customer is headed south" do
      ticket = Ticket.new("Providence, RI", "Stamford, CT", "Blake Lowell")
      expect(Ticket).to receive(:new).exactly(3).times.with("Providence, RI", "Stamford, CT", "Blake Lowell").and_return(ticket)
      
      providence_vm.purchase_tickets("Stamford, CT", 3, "Blake Lowell")
      stations = fetch_involved_stations(acela, "Providence, RI", "Stamford, CT")
      stations.each do |station_name, i|
        original = acela[i]["remaining seats"]
        expect(providence_vm.route[i]["remaining seats"]).to eq(original - 3)
      end
    end

    let(:santa_barbara_vm) { VendingMachine.new(surfliner_file,"Santa Barbara, CA")   }
    let(:san_luis_vm)      { VendingMachine.new(surfliner_file,"San Luis Obispo, CA") }
    let(:grover_beach_vm)     { VendingMachine.new(surfliner_file,"Grover Beach, CA" )   }

    let(:not_enough_seats_middle) { surf_vm.purchase_tickets("Ventura, CA", 1, "Amy Poehler") }
    let(:not_enough_seats_begin) { santa_barbara_vm.purchase_tickets("Fullerton, CA", 1, "Chelsea Peretti") }
    let(:not_enough_seats_end) { san_luis_vm.purchase_tickets("Carpinteria, CA", 1, "Sarah Silverman") }
    let(:passenger_exits_after_train_fills_up) { grover_beach_vm.purchase_tickets("Santa Barbara, CA", 1, "Zach Galifianakis") }
    
    it "apologizes because of a full train in middle of ride and doesn't buy tickets" do
      ticket_count = surf_vm.tickets.length
      expect(Ticket).to_not receive(:new)      
      expect(not_enough_seats_middle).to eq(sorry)
      expect(surf_vm.tickets.length).to eq(ticket_count)
    end

    it "apologizes because of a full train in beginning of ride and doesn't buy tickets" do
      ticket_count = santa_barbara_vm.tickets.length
      expect(Ticket).to_not receive(:new)      
      expect(not_enough_seats_begin).to eq(sorry)
      expect(santa_barbara_vm.tickets.length).to eq(ticket_count)
    end

    it "apologizes because of a full train at end of ride and doesn't buy tickets" do
      ticket_count = san_luis_vm.tickets.length
      expect(Ticket).to_not receive(:new)      
      expect(not_enough_seats_end).to eq(sorry)
      expect(san_luis_vm.tickets.length).to eq(ticket_count)
    end

    it "purchases tickets when the train doesn't get full until after the passenger gets off" do
      ticket_count = grover_beach_vm.tickets.length
      ticket = Ticket.new("Grover Beach, CA", "Santa Barbara, CA", "Zach Galifianakis")
      expect(Ticket).to receive(:new).with("Grover Beach, CA", "Santa Barbara, CA", "Zach Galifianakis").once.and_return(ticket)     
      
      expect(passenger_exits_after_train_fills_up).to eq(thank_you)
      expect(grover_beach_vm.tickets.length).to eq(ticket_count + 1)
      expect(grover_beach_vm.tickets).to include(ticket)
    end

    it "does not issue a ticket if there aren't enough seats" do
      ticket_count = acela_machine.tickets.length
      expect(Ticket).to_not receive(:new)
      
      surf_vm.purchase_tickets("Ventura, CA", 1, "Javier O'Hara")
      expect(surf_vm.tickets.length).to eq(ticket_count)
    end
  end
end
