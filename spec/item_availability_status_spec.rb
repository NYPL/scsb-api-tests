require_relative './spec_helper'

describe 'ItemAvailabilityStatus' do
  it '4. Verify that when one or more items are looked up by barcode, each availability status is returned.', number:4 do
    [
      # This one is (at writing) requested in test number:1, so we expect that
      # test to have been run first, resulting in the following status:
      {
        barcode: '33433116343660',
        expected_status: 'Not Available'
      },
      {
        barcode: '33433034009526',
        expected_status: 'Available'
      }
    ].each do |query|
      path = '/sharedCollection/itemAvailabilityStatus'

      body = {
        "barcodes": [query[:barcode]]
      }

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      # Example:
      # [{"itemBarcode":"33433116343660","itemAvailabilityStatus":"Not Available","errorMessage":null}]

      expect(record).to be_a(Array)
      expect(record.size).to eq(1)
      expect(record.first).to be_a(Hash)
      expect(record.first["itemBarcode"]).to eq(query[:barcode])
      found_status = record.first["itemAvailabilityStatus"]
      expect(found_status).to eq(query[:expected_status])

      Logger.debug "Found #{query[:barcode]} status of '#{found_status}', as expected\n"
    end
  end
end
