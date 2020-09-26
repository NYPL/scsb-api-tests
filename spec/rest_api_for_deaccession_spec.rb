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
end
