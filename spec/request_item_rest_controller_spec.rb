require_relative './spec_helper'

describe 'Request Item Rest Controller' do
  describe 'holds' do
    body = nil
    before(:each) do
      body = {
        bibId: 7825107,
        title: "An account of the closing exercises of the Panama-Pacific international exposition, San Francisco, December fourth, 1915.",
        author: " Panama-Pacific International Exposition Company.  ",
        pickupLocation: "NH",
        patronIdentifier: '23333090799527',
        itemBarcodes: [
          '33433074450028'
        ],
        itemOwningInstitution: "NYPL"
      }
    end

    it '19. Verify that Recap User can create a hold', deprecated:true do
      path = '/requestItem/holdItem'

      barcode = body[:itemBarcodes].first
      item = item_by_barcode barcode
      raise "Problem with chosen test item (#{barcode}): It's not not available" if item['availability'] != 'Available'

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      puts "TODO: Verify hold placed for patron in Test Sierra"

      expect(record).to be_a(Hash)
      expect(record['itemBarcode']).to eq(barcode)
      expect(record['success']).to eq(true)
      expect(record['screenMessage']).to match(/^Job finished successfully for hold request. \(RequestID: \d+\)$/)
    end

    it '14. Verify that Recap User can cancel a hold', deprecated:true do
      path = '/requestItem/cancelHoldItem'

      barcode = body[:itemBarcodes].first

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      puts "TODO: Verify hold removed for patron in Test Sierra"

      expect(record).to be_a(Hash)
      expect(record['itemBarcode']).to eq(barcode)
      expect(record['success']).to eq(true)
      expect(record['screenMessage']).to match(/^Job finished successfully for hold request. \(CancelID: \d+\)$/)
    end
  end

  describe 'request item' do
    body = nil
    before(:each) do
      body = {
        author: " Panama-Pacific International Exposition Company.  ",
        bibId: 7825107,
        deliveryLocation: 'NH',
        itemBarcodes: [
          '33433116343660'
        ],
        itemOwningInstitution: "NYPL",
        patronBarcode: '23333090799527',
        titleIdentifier: "An account of the closing exercises of the Panama-Pacific international exposition, San Francisco, December fourth, 1915.",
        requestType: 'RETRIEVAL',
        requestingInstitution: 'NYPL'
      }
    end

    it '1. Verify that a request can be created through the API.', number:1 do
      path = '/requestItem/requestItem'

      barcode = body[:itemBarcodes].first

      Logger.debug "Verifying #{barcode} is available"
      status = item_status(body[:itemBarcodes].first)
      expect(status).to eq('Available')

      Logger.debug "Posting requestItem for item #{body[:itemBarcodes].first}"
      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      expect(record).to be_a(Hash)
      expect(record['itemBarcodes']).to be_a(Array)
      expect(record['itemBarcodes'].first).to eq(body[:itemBarcodes].first)
      expect(record['success']).to eq(true)
      expect(record['screenMessage']).to eq('Message received, your request will be processed')

      Logger.debug "Verifying #{barcode} is no longer available"
      status = item_status(body[:itemBarcodes].first)
      expect(status).to eq('Not Available')
    end

    it '15. Verify that Recap user can Cancel the request through API service', deprecated:true do
      puts "TODO: This is brittle because we're hard-coding a requestId that has already been canceled"
      # This request id can be found by searching for the request in UAT UI (Request > Search Requests)
      # and then geting the @value of the input in table#request-result-table > tbody > tr > input
      # for the relevant item
      path = '/requestItem/cancelRequest?requestId=755004'

      response = post path

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      expect(record).to be_a(Hash)
      expect(record['success']).to eq(true)
      expect(record['screenMessage']).to eq('Request cancellation successfully processed')
    end
  end

  describe 'itemInformation' do
    it '16. Verify that Recap user can view the item information as part of the request API workflow.', deprecated:true do
      path = '/requestItem/itemInformation'
      body = {
        itemBarcodes: [
          '33433116343660'
        ],
        itemOwningInstitution: 'NYPL'
      }

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      # e.g.: {"itemBarcode"=>"33433116343660", "itemOwningInstitution"=>"", "screenMessage"=>nil, "success"=>true, "esipDataIn"=>nil, "esipDataOut"=>nil, "expirationDate"=>nil, "titleIdentifier"=>nil, "dueDate"=>"", "circulationStatus"=>"IN TRANSIT", "securityMarker"=>nil, "feeType"=>nil, "transactionDate"=>nil, "holdQueueLength"=>"0", "holdPickupDate"=>nil, "recallDate"=>nil, "mediaType"=>nil, "permanentLocation"=>nil, "currentLocation"=>"OFFSITE - Request in Advance", "bibID"=>"13120836", "currencyType"=>nil, "callNumber"=>"NBQ (Coudert, F. R. Addresses)", "itemType"=>nil, "bibIds"=>["13120836"], "source"=>"sierra-nypl", "createdDate"=>"02-11-2009 14:14:04", "updatedDate"=>"08-25-2020 23:55:53", "deletedDate"=>"", "owner"=>nil, "isbn"=>nil, "lccn"=>nil, "deleted"=>false}

      expect(record).to be_a(Hash)
      expect(record['itemBarcode']).to eq('33433116343660')
      expect(record['success']).to eq(true)
      expect(record['bibID']).to eq('13120836')
    end
  end

  describe 'patronInformation' do
    it '21. Verify that Recap user can obtain Patron information through API workflow.', deprecated:true do
      path = '/requestItem/patronInformation'
      body = {
        patronIdentifier: '23333090799527',
        itemOwningInstitution: 'NYPL'
      }

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      puts "TODO: This endpoint currently returns an empty body"
    end
  end

  describe 'refile' do
    it '23. Verify that Recap user can Refile the request item through API workflow.', deprecated:true do
      path = '/requestItem/refile'
      body = {
        itemBarcodes: [
          '33433116343660'
        ]
      }

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      # e.g. {"itemBarcode":null,"itemOwningInstitution":"","screenMessage":"Successfully Refiled","success":true,"esipDataIn":null,"esipDataOut":null}

      expect(record).to be_a(Hash)
      expect(record['screenMessage']).to eq('Successfully Refiled')
      expect(record['success']).to eq(true)
    end
  end
end
