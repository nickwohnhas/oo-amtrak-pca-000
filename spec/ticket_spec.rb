describe "Ticket" do

  describe "#initialize" do
    it "is initialized with three arguments: origin, destination, and name" do
      expect { Ticket.new("Providence, RI", "Wilmington, DE", "Rodrigo Santoro") }.to_not raise_error
    end
  end

  let(:east_coast_ticket) { Ticket.new("Wilmington, DE", "Providence, RI", "Mel Fronckowiak") }
  let(:west_coast_ticket) { Ticket.new("Camarillo, CA", "Solana Beach, CA", "Selena Gomez")   }
  let(:tickets) { [east_coast_ticket, west_coast_ticket] }   

  describe "#origin" do 
    it "knows the origin train station" do
      expect(east_coast_ticket.origin).to eq("Wilmington, DE")
      expect(west_coast_ticket.origin).to eq("Camarillo, CA")
    end
  end

  describe "#destination" do 
    it "knows the destination train station" do
      expect(east_coast_ticket.destination).to eq("Providence, RI")
      expect(west_coast_ticket.destination).to eq("Solana Beach, CA")
    end
  end

  describe "#name" do 
    it "knows the name of the ticket purchaser" do
      expect(east_coast_ticket.name).to eq("Mel Fronckowiak")
      expect(west_coast_ticket.name).to eq("Selena Gomez")
    end
  end

end