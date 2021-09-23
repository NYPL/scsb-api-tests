require_relative './spec_helper'

describe 'Search' do
  describe '2. Verify that the search API returns the expected items.', number:2 do
    [
      {
        barcode: 'CU75061864',
        institution: 'CUL'
      },
      {
        barcode: 'HX295W',
        institution: 'HL'
      },
      {
        barcode: '32101099217760',
        institution: 'PUL'
      },
      {
        barcode: '33433034659452',
        institution: 'NYPL'
      }
    ].each do |query|
      it "search by #{query[:institution]} barcode #{query[:barcode]}" do
        path = '/searchService/search'

        body = {
          "deleted": false,
          "fieldValue": query[:barcode],
          "fieldName": "Barcode",
          "owningInstitutions": [
            query[:institution]
          ]
        }

        response = post path, body

        expect(response.code.to_i).to eq(200)
        expect(response['Content-Type']).to match(/^application\/json/)

        record = JSON.parse response.body
        expect(record).to be_a(Hash)
        expect(record["searchResultRows"]).to be_a(Array)
        expect(record["searchResultRows"].first).to be_a(Hash)
        expect(record["searchResultRows"].first["owningInstitution"]).to eq(query[:institution])
        expect(record["searchResultRows"].first["barcode"]).to eq(query[:barcode])
      end
    end
  end
end
