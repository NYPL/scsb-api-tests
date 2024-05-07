require_relative './spec_helper'

describe 'deaccession' do
  it '8. Verify that if multiple items are included in single call, all bibs and holdings are deleted.', number:8 do
    records = [
      {
        deliveryLocation: 'NA',
        itemBarcode: '33433117925671'
      },
      {
        deliveryLocation: 'NA',
        itemBarcode: '33433012013078'
      }
    ]

    barcodes = records.map { |record| record[:itemBarcode] }
    Logger.debug "# Fetching target items: #{barcodes.join(', ')}"
    barcodes.each do |barcode|
      item = item_by_barcode barcode

      expect(item).to be_a(Hash)
    end

    Logger.debug "# Deaccessioning items"
    # Deaccession two items:
    response = post '/sharedCollection/deaccession', {
      deAccessionItems: records,
      username: ENV['API_USERNAME']
    }

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    result = JSON.parse response.body

    p result

    # e.g. {"33433088232933":"Success","33433064251923":"Success"}

    Logger.debug "# Confirming items have been deleted"
    records.map { |r| r[:itemBarcode] }.each do |barcode|
      expect(result[barcode]).to eq('Success')

      # Confirm item is gone:
      expect { item_by_barcode(barcode) }.to raise_error("Could not find item by barcode: #{barcode}")
    end
  end

  it '39. Verify that if user provides a barcode that already has been deaccessioned then application should display an error message.', deprecated:true do
    path = '/sharedCollection/deaccession'

    barcode = '33433128993643'
    body = {
      deAccessionItems: [
        {
          deliveryLocation: 'NA',
          itemBarcode: barcode
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"33433066644091":"Failure - The requested item has already been deaccessioned."}

    expect(record).to be_a(Hash)
    expect(record[barcode]).to eq('Failure - The requested item has already been deaccessioned.')
  end

  describe 'Test 9' do
    barcode = 'qwerty'

    before(:each) do
      # Ensure item is already deaccessioned
      body = {
        deAccessionItems: [
          {
            deliveryLocation: 'NA',
            itemBarcode: barcode
          }
        ],
        username: ENV['API_USERNAME']
      }

      resp = post '/sharedCollection/deaccession', body
    end

    # Note: This test is oddly worded, but it's really a test of the API response to invalid barcodes
    it '9. Verify that if user provides invalid parameter (other than the barcode) through the deaccession api service, application should display the failure error message.', number:9 do
      path = '/sharedCollection/deaccession'

      # Barcode defined above
      Logger.debug "# Attempting to deaccession #{barcode}, which is invalid (because it has already been deaccessioned)"

      body = {
        deAccessionItems: [
          {
            deliveryLocation: 'NA',
            itemBarcode: barcode
          }
        ],
        username: ENV['API_USERNAME']
      }

      response = post path, body

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      # e.g. {"33433120661248":"Failure - The requested item has already been deaccessioned."}

      expect(record).to be_a(Hash)
      expect(record[barcode]).to eq('Failure - Item barcode doesn\'t exist in SCSB database.')
    end
  end

  describe 'Test 36' do
    barcode = '33433063664720'
    customer_code = 'NP'

    after(:each) do
      # Lastly, reaccession it:
      post '/sharedCollection/accession', [
        {
          customerCode: customer_code,
          itemBarcode: barcode
        }
      ]
    end

    it '36. Verify that if user trying to deaccession a single Item record which has multiple item and Holdings attached to it (bound-with) then application should update delete flag for corresponding item and the bib and holding records.', deprecated:true do

      # Deaccession a single item from a multi-item bib:
      response = post '/sharedCollection/deaccession', {
        deAccessionItems: [
          {
            deliveryLocation: customer_code,
            itemBarcode: barcode
          }
        ]
      }

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^application\/json/)

      record = JSON.parse response.body

      # e.g. {"33433063664720":"Success"}

      expect(record).to be_a(Hash)
      expect(record[barcode]).to eq('Success')

      # Confirm item is gone:
      expect { item_by_barcode(barcode) }.to raise_error("Could not find item by barcode: #{barcode}")

      # Fetch sibling item:
      sibling = item_by_barcode('33433063513190')

      expect(sibling).to be_a(Hash)
      expect(sibling['barcode']).to eq('33433063513190')
    end
  end

  it '37. Application should perform deaccession  for an item but the bib has attached with multiple items. Then, the item should be flagged has deletion and not for bib and holdings.', deprecated:true do

    bnum = '.b131115674'
    items = items_by_bnum bnum

    expect(items).to be_a(Array)
    expect(items.size).to eq(2)

    first_barcode = items.first['barcode']

    puts "# Verified that #{bnum} has two items. Deaccessioning first.."

    path = '/sharedCollection/deaccession'
    body = { deAccessionItems: [ { deliveryLocation: 'NA', itemBarcode: first_barcode } ] }
    response = post path, body

    sibling_result = item_by_barcode items.last['barcode']
    expect(sibling_result).to be_a(Hash)

    expect { item_by_barcode(first_barcode) }.to raise_error

  end

  it '10. BOUND WITH: Verify that if user tries to deaccession a single Item record which has multiple item and holdings attached to it, then the application should update delete flag for corresponding item and the bib and holding records.', deprecated:true do

    # Sample barcodes:
    #   33433011646076
    #   33433011646050
    #   33433011646043
    #   33433011646035
    #   33433011646076
    barcode = '33433011646068'

    Logger.debug "# Fetching target item: #{barcode}"
    item = item_by_barcode barcode

    expect(item).to be_a(Hash)

    Logger.debug "# Verifying the item has multiple bibs (is a bound-with)"
    bnums = bnums_by_barcode barcode
    expect(bnums).to be_a(Array)
    expect(bnums.size).to be >= 2
    Logger.debug "#   item has #{bnums.size} bibs"

    Logger.debug "# Verifying the item has multiple holdings ids"
    holdings_ids = holdings_ids_by_barcode barcode
    expect(holdings_ids).to be_a(Array)
    expect(holdings_ids.size).to be >= 2
    Logger.debug "#   item has #{holdings_ids.size} holdings"

    Logger.debug "# Deaccessioning #{barcode}"

    body = {
      deAccessionItems: [
        {
          deliveryLocation: 'NA',
          itemBarcode: barcode
        }
      ],
      username: ENV['API_USERNAME']
    }

    path = '/sharedCollection/deaccession'
    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"33433109761407":"Success"}

    expect(record).to be_a(Hash)
    expect(record[barcode]).to eq('Success')

    Logger.debug "# Verifying deaccessioned"

    expect { item_by_barcode(barcode) }.to raise_error("Could not find item by barcode: #{barcode}")
  end

  it '8. BOUND WITH: Verify that if user tries to deaccession an item record which has single holding and multiple bibs, then the application should update delete flag for item, holding and bib records.', deprecated:true do

    barcode = '33433109761407'

    Logger.debug "# Fetching target item: #{barcode}"
    item = item_by_barcode barcode

    expect(item).to be_a(Hash)

    Logger.debug "# Verifying the item has multiple bibs (is a bound-with)"
    bnums = bnums_by_barcode barcode
    expect(bnums).to be_a(Array)
    expect(bnums.size).to eq(2)

    Logger.debug "# Fetching sibling items under bib #{item['owningInstitutionBibId']}"
    items = items_by_bnum item['owningInstitutionBibId']

    expect(items).to be_a(Array)
    expect(items.length).to be >= 100

    Logger.debug "# Deaccessioning #{barcode}"

    body = {
      deAccessionItems: [
        {
          deliveryLocation: 'NA',
          itemBarcode: barcode
        }
      ]
    }

    path = '/sharedCollection/deaccession'
    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"33433109761407":"Success"}

    expect(record).to be_a(Hash)
    expect(record[barcode]).to eq('Success')

    Logger.debug "# Verifying deaccessioned"

    expect { item_by_barcode(barcode) }.to raise_error("Could not find item by barcode: #{barcode}")

    items = items_by_bnum '.b118114268'
    expect(items).to be_a(Array)
    expect(items.size).to be > 100
  end
end
