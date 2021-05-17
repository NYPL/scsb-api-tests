require_relative './spec_helper'

describe 'accession' do
  it '26. Verify that user can enable deaccession[ed] item record through accession api service.', number:26 do
    barcode = '33433086962713'
    customer_code = 'NA'

    Logger.debug "# Deaccessioning #{barcode}"
    # First deaccession it:
    resp = post '/sharedCollection/deaccession', {
      deAccessionItems: [
        {
          deliveryLocation: customer_code,
          itemBarcode: barcode
        }
      ]
    }

    Logger.debug "# Verifying item deleted"

    item = item_by_barcode(barcode, deleted: true)
    expect(item).to be_a(Hash)
    expect(item['barcode']).to eq(barcode)

    Logger.debug "# Re-accessioning #{barcode}"
    path = '/sharedCollection/accession'
    body = {
      accessionRequests: [
        {
          customerCode: customer_code,
          itemBarcode: barcode
        }
      ],
      imsLocationCode: 'RECAP'
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. [{"itemBarcode":"33433128984121","message":"Success"}]

    expect(record).to be_a(Array)
    expect(record.size).to eq(1)
    expect(record.first).to be_a(Hash)
    expect(record.first['message']).to eq('Success')

    Logger.debug "# Verifying item discoverable"

    item = item_by_barcode(barcode)
    expect(item).to be_a(Hash)
    expect(item['barcode']).to eq(barcode)
  end

  it '27. Verify that if user provides a barcode/customer code that is a duplicate of an item already in the system,  then application should display an appropriate error message.', number:27 do
    path = '/sharedCollection/accession'
    body = {
      accessionRequests: [
        {
          customerCode: 'NA',
          itemBarcode: '33433020619338'
        }
      ],
      imsLocationCode: 'RECAP'
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    # e.g. [{"itemBarcode":"33433020619338","message":"Item already accessioned - Existing item details :  OwningInstBibId-.b139369600 OwningInstHoldingId-0be70924-fedd-4b52-b350-d17145d5c579 OwningInstItemId-.i123289130"}]

    record = JSON.parse response.body
    expect(record).to be_a(Array)
    expect(record.size).to eq(1)
    expect(record.first).to be_a(Hash)
    expect(record.first['message']).to start_with('Item already accessioned - Existing item details')
  end
end
