require_relative './spec_helper'

describe 'BibAvailabilityStatus' do
  it '3. Verify availability returned when an item is looked up by BIB ID and owning institution', number:3 do
    [
      # These may need to be updated to reference a couple items with different statuses:
      {
        bibid: '.b139146222',
        items: [
          {
            barcode: '33433022997773',
            expected_status: 'Not Available'
          }
        ]
      },
      {
        bibid: '.b13430486x',
        items: [
          {
            barcode: '33433098469640',
            expected_status: 'Available'
          }
        ]
      }
    ].each do |query|
      path = '/sharedCollection/bibAvailabilityStatus'

      body = {
        "bibliographicId": query[:bibid],
        "institutionId": "NYPL"
      }

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      # Example:
      # [{"itemBarcode":"33433022997773","itemAvailabilityStatus":"Not Available","errorMessage":null,"collectionGroupDesignation":"Open"}]

      expect(record).to be_a(Array)
      expect(record.size).to eq(1)
      expect(record.first).to be_a(Hash)

      query[:items].each do |item|
        item_response = record.find { |response_item| response_item["itemBarcode"] == item[:barcode] }
        expect(item_response["itemAvailabilityStatus"]).to eq(item[:expected_status])

        Logger.debug "Found bib #{query[:bibid]}, item #{item[:barcode]} status of '#{item[:expected_status]}', as expected\n"
      end
    end
  end
end
