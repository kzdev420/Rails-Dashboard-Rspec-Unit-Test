['200', '201', '401', '403', '404', '422', '400'].each do |code|
  RSpec.shared_examples "response_#{code}" do |options={}|
    it "response should have #{code} status", options do
      subject
      expect(response.code).to eq(code)
    end
  end
end
