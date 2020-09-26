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
          '33433034659452'
        ],
        itemOwningInstitution: "NYPL"
      }
    end

    it '19. Verify that Recap User can create a hold', number:19 do
      path = '/requestItem/holdItem'

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      puts "TODO: Verify hold placed for patron in Test Sierra"

      expect(record).to be_a(Hash)
      expect(record['itemBarcode']).to eq('33433034659452')
      expect(record['success']).to eq(true)
      expect(record['screenMessage']).to match(/^Job finished successfully for hold request. \(RequestID: \d+\)$/)
    end

    it '14. Verify that Recap User can cancel a hold', number:14 do
      path = '/requestItem/cancelHoldItem'

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      puts "TODO: Verify hold removed for patron in Test Sierra"

      expect(record).to be_a(Hash)
      expect(record['itemBarcode']).to eq('33433034659452')
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

    it '24. Verify that Recap user can request the item through API workflow.', number:24 do
      path = '/requestItem/requestItem'

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      puts "TODO: Verify hold placed for patron in Test Sierra"

      expect(record).to be_a(Hash)
      expect(record['itemBarcodes']).to be_a(Array)
      expect(record['itemBarcodes'].first).to eq('33433116343660')
      expect(record['success']).to eq(true)
      expect(record['screenMessage']).to eq('Message received, your request will be processed')

    end

    it '15. Verify that Recap user can Cancel the request through API service', number:15 do
      puts "TODO: This is brittle because we're hard-coding a requestId that has already been canceled"
      path = '/requestItem/cancelRequest?requestId=707890'

      response = post path

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      expect(record).to be_a(Hash)
      expect(record['success']).to eq(true)
      expect(record['screenMessage']).to eq('Request cancellation succcessfully processed')
    end
  end

  describe 'itemInformation' do
    it '16. Verify that Recap user can view the item information as part of the request API workflow.', number:16 do
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
    it '21. Verify that Recap user can obtain Patron information through API workflow.', number:21 do
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
    it '23. Verify that Recap user can Refile the request item through API workflow.', number:23 do
      path = '/requestItem/refile'
      body = {
        itemBarcodes: [
          '33433116343660'
        ],
        requestIds: [707890]
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
