require_relative './spec_helper'

describe 'deaccession' do
  it '39. Verify that if user provides a barcode that already has been deaccessioned then application should display an error message.', number:39 do
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

  it '42. Verify that if user provides invalid parameter(other than Barcode) through Deaccession api service, application should display the failure error message', number:42 do
    path = '/sharedCollection/deaccession'

    body = {
      deAccessionItems: [
        {
          deliveryLocation: 'NA',
          itemBarcode: '334330666440919999',
          foo: 'bar'
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"itemBarcode":null,"itemOwningInstitution":"","screenMessage":"Successfully Refiled","success":true,"esipDataIn":null,"esipDataOut":null}

    expect(record).to be_a(Hash)
    expect(record['screenMessage']).to eq('Successfully Refiled')
    expect(record['body'].deAccessionItems[0].itemBarcode).to eq(true)
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

    it '36. Verify that if user trying to deaccession a single Item record which has multiple item and Holdings attached to it (bound-with) then application should update delete flag for corresponding item and the bib and holding records.', number:36 do

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
end
