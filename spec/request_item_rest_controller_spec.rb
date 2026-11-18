require_relative './spec_helper'

def request_item(barcode)
  Logger.debug "Posting requestItem for item #{barcode}"
  body = {
    author: 'Last, first',
    bibId: '123',
    deliveryLocation: 'NH',
    itemBarcodes: [
      barcode
    ],
    itemOwningInstitution: 'NYPL',
    patronBarcode: '23333090799527',
    titleIdentifier: 'Adventure on wheels; the autobiography of a road racing champion by John Fitch...',
    requestType: 'RETRIEVAL',
    requestingInstitution: 'NYPL'
  }
  response = post '/requestItem/requestItem', body

  expect(response.code.to_i).to eq(200)
  expect(response['Content-Type']).to match(%r{^application/json})

  record = JSON.parse response.body

  expect(record).to be_a(Hash)
  expect(record['itemBarcodes']).to be_a(Array)
  expect(record['itemBarcodes'].first).to eq(body[:itemBarcodes].first)
  expect(record['success']).to eq(true)
  expect(record['screenMessage']).to eq('Message received, your request will be processed')
end

def request_status(barcode, options = {})
  path = '/requestItem/requestStatus'
  body = {
    barcodes: [
      barcode
    ]
  }
  response = post path, body, options

  # Expect response resembling:  e.g. [{"deliveryLocation":"NH","errorMessage":null,"itemBarcode":"33433034659452","owningInstitution":"NYPL","requestId":"1064279","requestType":"RETRIEVAL","requestingInstitution":"NYPL","screenMessage":null,"status":"RETRIEVAL ORDER PLACED"}]
  expect(response.code.to_i).to eq(200)
  expect(response['Content-Type']).to match(%r{^application/json})
  results = JSON.parse response.body
  expect(results).to be_a(Array)
  expect(results.size).to eq(1)

  results[0]['status']
end

describe 'Request Item Rest Controller' do
  describe 'holds' do
    body = nil
    before(:each) do
      body = {
        bibId: 7_825_107,
        title: 'An account of the closing exercises of the Panama-Pacific international exposition, San Francisco, December fourth, 1915.',
        author: ' Panama-Pacific International Exposition Company.  ',
        pickupLocation: 'NH',
        patronIdentifier: '23333090799527',
        itemBarcodes: [
          '33433074450028'
        ],
        itemOwningInstitution: 'NYPL'
      }
    end

    it 'Verify that Recap User can create a hold', deprecated: true do
      path = '/requestItem/holdItem'

      barcode = body[:itemBarcodes].first
      item = item_by_barcode barcode
      raise "Problem with chosen test item (#{barcode}): It's not not available" if item['availability'] != 'Available'

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(%r{^application/json})

      record = JSON.parse response.body

      puts 'TODO: Verify hold placed for patron in Test Sierra'

      expect(record).to be_a(Hash)
      expect(record['itemBarcode']).to eq(barcode)
      expect(record['success']).to eq(true)
      expect(record['screenMessage']).to match(/^Job finished successfully for hold request. \(RequestID: \d+\)$/)
    end

    it 'Verify that Recap User can cancel a hold', deprecated: true do
      path = '/requestItem/cancelHoldItem'

      barcode = body[:itemBarcodes].first

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(%r{^application/json})

      record = JSON.parse response.body

      puts 'TODO: Verify hold removed for patron in Test Sierra'

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
        author: 'Fitch, John, 1917- ',
        bibId: 6_052_616,
        deliveryLocation: 'NH',
        itemBarcodes: [
          '33433022997773'
        ],
        itemOwningInstitution: 'NYPL',
        patronBarcode: '23333090799527',
        titleIdentifier: 'Adventure on wheels; the autobiography of a road racing champion by John Fitch, with William W. Nolan.',
        requestType: 'RETRIEVAL',
        requestingInstitution: 'NYPL'
      }
    end

    it 'Verify that a request can be created through the API.', number: 1 do
      path = '/requestItem/requestItem'

      barcode = body[:itemBarcodes].first

      Logger.debug "Verifying #{barcode} is available"
      status = item_status(body[:itemBarcodes].first)
      expect(status).to eq('Available')

      Logger.debug "Posting requestItem for item #{body[:itemBarcodes].first}"
      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(%r{^application/json})

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

    it 'Verify that Recap user can Cancel the request through API service', deprecated: true do
      puts "TODO: This is brittle because we're hard-coding a requestId that has already been canceled"
      # This request id can be found by searching for the request in UAT UI (Request > Search Requests)
      # and then geting the @value of the input in table#request-result-table > tbody > tr > input
      # for the relevant item
      path = '/requestItem/cancelRequest?requestId=755004'

      response = post path

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(%r{^application/json})

      record = JSON.parse response.body

      expect(record).to be_a(Hash)
      expect(record['success']).to eq(true)
      expect(record['screenMessage']).to eq('Request cancellation successfully processed')
    end
  end

  describe 'itemInformation' do
    it 'Verify that Recap user can view the item information as part of the request API workflow.',
       deprecated: true do
      path = '/requestItem/itemInformation'
      body = {
        itemBarcodes: [
          '33433116343660'
        ],
        itemOwningInstitution: 'NYPL'
      }

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(%r{^application/json})

      record = JSON.parse response.body

      # e.g.: {"itemBarcode"=>"33433116343660", "itemOwningInstitution"=>"", "screenMessage"=>nil, "success"=>true, "esipDataIn"=>nil, "esipDataOut"=>nil, "expirationDate"=>nil, "titleIdentifier"=>nil, "dueDate"=>"", "circulationStatus"=>"IN TRANSIT", "securityMarker"=>nil, "feeType"=>nil, "transactionDate"=>nil, "holdQueueLength"=>"0", "holdPickupDate"=>nil, "recallDate"=>nil, "mediaType"=>nil, "permanentLocation"=>nil, "currentLocation"=>"OFFSITE - Request in Advance", "bibID"=>"13120836", "currencyType"=>nil, "callNumber"=>"NBQ (Coudert, F. R. Addresses)", "itemType"=>nil, "bibIds"=>["13120836"], "source"=>"sierra-nypl", "createdDate"=>"02-11-2009 14:14:04", "updatedDate"=>"08-25-2020 23:55:53", "deletedDate"=>"", "owner"=>nil, "isbn"=>nil, "lccn"=>nil, "deleted"=>false}

      expect(record).to be_a(Hash)
      expect(record['itemBarcode']).to eq('33433116343660')
      expect(record['success']).to eq(true)
      expect(record['bibID']).to eq('13120836')
    end
  end

  describe 'patronInformation' do
    it 'Verify that Recap user can obtain Patron information through API workflow.', deprecated: true do
      path = '/requestItem/patronInformation'
      body = {
        patronIdentifier: '23333090799527',
        itemOwningInstitution: 'NYPL'
      }

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(%r{^application/json})

      JSON.parse response.body

      puts 'TODO: This endpoint currently returns an empty body'
    end
  end

  describe 'refile' do
    it 'Verify that Recap user can Refile the request item through API workflow.', deprecated: true do
      path = '/requestItem/refile'
      body = {
        itemBarcodes: [
          '33433116343660'
        ]
      }

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(%r{^application/json})

      record = JSON.parse response.body

      # e.g. {"itemBarcode":null,"itemOwningInstitution":"","screenMessage":"Successfully Refiled","success":true,"esipDataIn":null,"esipDataOut":null}

      expect(record).to be_a(Hash)
      expect(record['screenMessage']).to eq('Successfully Refiled')
      expect(record['success']).to eq(true)
    end
  end

  describe 'requestStatus' do
    it 'Verify that when one or more items are looked up by barcode the status'\
       ' and other information about the item and its request status is returned', number: 5 do
      barcode = select_random_nypl_barcode()

      Logger.debug "Verifying #{barcode} is available"
      current_status = item_status(barcode)
      expect(current_status).to eq('Available')

      request_item(barcode)

      start = Time.now
      statuses = []
      # For 60s, poll API for request status:
      polling_period = 60
      polling_frequency_per_s = 2.0
      for _i in 0..(polling_period * polling_frequency_per_s) do
        new_status = request_status(barcode, { quiet: true })

        if statuses.empty? || statuses[-1][:status] != new_status
          ellapsed = Time.now - start
          statuses.push(
            {
              status: new_status,
              time: ellapsed
            }
          )
          Logger.debug "Request status changed to #{new_status} after #{ellapsed}s"
        end

        break if new_status == 'RETRIEVAL ORDER PLACED'

        sleep 1.0 / polling_frequency_per_s
      end

      # Expect collected statuses to resemble:
      # [{:status=>"PROCESSING ...", :time=>2026-11-16 11:51:18.342842 -0500}, {:status=>"PENDING", :time=>2026-11-16 11:51:38.458475 -0500}, {:status=>"RETRIEVAL ORDER PLACED", :time=>2026-11-16 11:51:39.51687 -0500}]

      # Skip initial ERROR status if found in first position
      if statuses.size > 3 && statuses[0][:status] == 'ERROR'
        statuses.delete(0)
      end
      expect(statuses.size).to eq(3)
      expect(statuses[0][:status]).to eq('PROCESSING ...')
      expect(statuses[1][:status]).to eq('PENDING')
      expect(statuses[2][:status]).to eq('RETRIEVAL ORDER PLACED')

      Logger.debug "Verifying #{barcode} is no longer available"
      status = item_status(barcode)
      expect(status).to eq('Not Available')
    end
  end
end
