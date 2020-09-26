require_relative './spec_helper'

describe 'accession' do
  it '27. Verify that if user provides a barcode/customer code that is a duplicate of an item already in the system,  then application should display an appropriate error message.', number:27 do
    path = '/sharedCollection/accession'
    body = [
      {
        customerCode: 'NA',
        itemBarcode: '33433034659452'
      }
    ]

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
