require_relative './spec_helper'

def reset_parents_for_33433021082692
  # Ensure item 33433021082692 has correct holding, bib
  item = item_by_barcode('33433021082692')
  if item['owningInstitutionHoldingsId'] == 'b7982081-fe21-4b3d-a2b0-f9b7dd92fd5a'
    result = post '/sharedCollection/transferHoldingsAndItems', {
      "institution":"NYPL",
      "itemTransfers": [
        {
          "destination": {
            "owningInstitutionBibId":".b106749511",
            "owningInstitutionHoldingsId":"74cde0f1-3133-4034-8e3d-83c05df9692f",
            "owningInstitutionItemId":".i101510251"
          },
          "source": {
            "owningInstitutionBibId":".b106188483",
            "owningInstitutionHoldingsId":"b7982081-fe21-4b3d-a2b0-f9b7dd92fd5a",
            "owningInstitutionItemId":".i101510251"
          }
        }
      ]
    }
  end
end
     
describe 'TransferHoldingsAndItems' do
  before(:all) do
    # reset_parents_for_33433021082692
  end

  it "45. Verify that user can transfer the existing owning institution item id details from existing holding to another existing holding id's, only for the same institution.", number:45 do

    path = '/sharedCollection/transferHoldingsAndItems'
    # Attempt to transfer item 33433066644109...
    #       "owningInstitutionBibId": ".b131115674",
    #       "owningInstitutionHoldingsId": "ef24b823-aaf0-4b1c-8750-f55760979017",
    #       "owningInstitutionItemId": ".i168151662",
    # to holdings for item 33433066644091...
    #       "owningInstitutionBibId": ".b131115674",
    #       "owningInstitutionHoldingsId": "c8e2a497-1a8f-46ac-8ebc-2e0004657690",
    #       "owningInstitutionItemId": ".i162579032",
    # Essentially, reassign an item's holdings id to an existing holdings id in the same bib
    body = {
      institution: "NYPL",
      itemTransfers: [
        {
          source: {
            owningInstitutionBibId: '.b131115674',
            owningInstitutionHoldingsId: 'ef24b823-aaf0-4b1c-8750-f55760979017',
            owningInstitutionItemId: '.i168151662'
          },
          destination: {
            owningInstitutionBibId: '.b131115674',
            owningInstitutionHoldingsId: 'c8e2a497-1a8f-46ac-8ebc-2e0004657690',
            owningInstitutionItemId: '.i168151662'
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Success","holdingTransferResponses":[],"itemTransferResponses":[{"message":"Successfully relinked","itemTransferRequest":{"source":{"owningInstitutionBibId":".b131115674","owningInstitutionHoldingsId":"ef24b823-aaf0-4b1c-8750-f55760979017","owningInstitutionItemId":".i168151662"},"destination":{"owningInstitutionBibId":".b131115674","owningInstitutionHoldingsId":"c8e2a497-1a8f-46ac-8ebc-2e0004657690","owningInstitutionItemId":".i168151662"}}}]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Success')
    expect(record['itemTransferResponses']).to be_a(Array)
    expect(record['itemTransferResponses'].first).to be_a(Hash)
    expect(record['itemTransferResponses'].first['message']).to eq('Successfully relinked')

  end

  it "46. Verify that user can't transfer the item or Holding id information for cross-institution BIB ids.", number:46 do
    path = '/sharedCollection/transferHoldingsAndItems'
    # Attempt to transfer item 33433086962713 to the holdings and bib for item CU01501267
    body = {
      institution: "NYPL",
      itemTransfers: [
        {
          destination: {
            owningInstitutionBibId: '1597029',
            owningInstitutionHoldingsId: '1972273',
            owningInstitutionItemId: '.i164310678'
          },
          source: {
            owningInstitutionBibId: '.b133423785',
            owningInstitutionHoldingsId: 'f165c759-82da-4920-814c-fc0246cd8aab',
            owningInstitutionItemId: '.i164310678'
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # TODO: This is currently failing to reject the illegal transfer, so unclear what response is expected
  end

  it "47. Verify that user can transfer the existing owning institution item id details from existing bib/holding to another existing bib/ holding id's, only for the same institution.", number:47 do
    path = '/sharedCollection/transferHoldingsAndItems'
    # Attempt to transfer item 33333059683314 to the holdings and bib for item 33433112694108
    body = {
      institution: "NYPL",
      itemTransfers: [
        {
          source: {
            owningInstitutionBibId: '.b171749716',
            owningInstitutionHoldingsId: '516b2f20-636f-45e0-bc67-a11a70f3bdc7',
            owningInstitutionItemId: '.i224742395'
          },
          destination: {
            owningInstitutionBibId: '.b198225040',
            owningInstitutionHoldingsId: 'a481c568-17e0-4d75-a01a-4f8385e33fa4',
            owningInstitutionItemId: '.i224742395'
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Success","holdingTransferResponses":[],"itemTransferResponses":[{"message":"Successfully relinked","itemTransferRequest":{"source":{"owningInstitutionBibId":".b171749716","owningInstitutionHoldingsId":"516b2f20-636f-45e0-bc67-a11a70f3bdc7","owningInstitutionItemId":".i224742395"},"destination":{"owningInstitutionBibId":".b198225040","owningInstitutionHoldingsId":"a481c568-17e0-4d75-a01a-4f8385e33fa4","owningInstitutionItemId":".i224742395"}}}]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Success')
    expect(record['itemTransferResponses']).to be_a(Array)
    expect(record['itemTransferResponses'].first).to be_a(Hash)
    expect(record['itemTransferResponses'].first['message']).to eq('Successfully relinked')
  end

  it "50. Verify that user can transfer existing owning institution holding id details from existing bib to another existing bib id's, only for the same institution.", number:50 do
    path = '/sharedCollection/transferHoldingsAndItems'
    # Attempt to transfer item 33433104476399's holding..:
    #       "owningInstitutionBibId": ".b210999913",
    #       "owningInstitutionHoldingsId": "e0d221d9-6eb7-4ede-8e20-81a3de1921b4",
    #       "owningInstitutionItemId": ".i346374972",
    # to the bib for 33433022271385:
    #       "owningInstitutionBibId": ".b144492477",
    #       "owningInstitutionHoldingsId": "ced5dc6a-4125-45b3-9470-6e2cce284cdf",
    #       "owningInstitutionItemId": ".i113562603",
    body = {
      institution: "NYPL",
      holdingTransfers: [
        {
          source: {
            owningInstitutionBibId: '.b210999913',
            owningInstitutionHoldingsId: 'e0d221d9-6eb7-4ede-8e20-81a3de1921b4'
          },
          destination: {
            owningInstitutionBibId: '.b144492477',
            owningInstitutionHoldingsId: 'e0d221d9-6eb7-4ede-8e20-81a3de1921b4'
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Success","holdingTransferResponses":[{"message":"Successfully relinked","holdingsTransferRequest":{"source":{"owningInstitutionBibId":".b210999913","owningInstitutionHoldingsId":"e0d221d9-6eb7-4ede-8e20-81a3de1921b4"},"destination":{"owningInstitutionBibId":".b144492477","owningInstitutionHoldingsId":"e0d221d9-6eb7-4ede-8e20-81a3de1921b4"}}}],"itemTransferResponses":[]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Success')
    expect(record['holdingTransferResponses']).to be_a(Array)
    expect(record['holdingTransferResponses'].first).to be_a(Hash)
    expect(record['holdingTransferResponses'].first['message']).to eq('Successfully relinked')
  end

  it "52. Verify that if the user trying to transfer invalid owning institution item id details to existing holding id's, then application should display an appropriate error message.", number:52 do
    path = '/sharedCollection/transferHoldingsAndItems'
    # Attempt to transfer item 33333023748987 (but intentionally flub the itemid):
    #       "owningInstitutionBibId": ".b171339083",
    #       "owningInstitutionHoldingsId": "9f8b5f99-0284-4c75-b637-b2d443839635",
    #       "owningInstitutionItemId": ".i224361302",
    # to holding for item 33433012102806:
    #       "owningInstitutionBibId": ".b147512797",
    #       "owningInstitutionHoldingsId": "3dde1988-bf5a-4ecc-9b3f-8191e56cf328",
    #       "owningInstitutionItemId": ".i240635085",
    body = {
      institution: "NYPL",
      itemTransfers: [
        {
          source: {
            owningInstitutionBibId: '.b171339083',
            owningInstitutionHoldingsId: '9f8b5f99-0284-4c75-b637-b2d443839635',
            owningInstitutionItemId: '.i224361302fladeedle'
          },
          destination: {
            owningInstitutionBibId: '.b147512797',
            owningInstitutionHoldingsId: '3dde1988-bf5a-4ecc-9b3f-8191e56cf328',
            owningInstitutionItemId: '.i224361302fladeedle'
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Failed","holdingTransferResponses":[],"itemTransferResponses":[{"message":"Source item is not under source holding","itemTransferRequest":{"source":{"owningInstitutionBibId":".b171339083","owningInstitutionHoldingsId":"9f8b5f99-0284-4c75-b637-b2d443839635","owningInstitutionItemId":".i224361302fladeedle"},"destination":{"owningInstitutionBibId":".b147512797","owningInstitutionHoldingsId":"3dde1988-bf5a-4ecc-9b3f-8191e56cf328","owningInstitutionItemId":".i224361302fladeedle"}}}]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Failed')
    expect(record['itemTransferResponses']).to be_a(Array)
    expect(record['itemTransferResponses'].first).to be_a(Hash)
    expect(record['itemTransferResponses'].first['message']).to eq('Source item is not under source holding')
  end

  it "53. Verify that if the user trying to transfer invalid owning institution holding details to existing bib id's, then application should display an appropriate error message.", number:53 do
    path = '/sharedCollection/transferHoldingsAndItems'
    # Attempt to transfer item 33333023748987's holding (but intentionally flub the holdingid):
    #       "owningInstitutionBibId": ".b171339083",
    #       "owningInstitutionHoldingsId": "9f8b5f99-0284-4c75-b637-b2d443839635",
    #       "owningInstitutionItemId": ".i224361302",
    # to bib for item 33433012102806:
    #       "owningInstitutionBibId": ".b147512797",
    #       "owningInstitutionHoldingsId": "3dde1988-bf5a-4ecc-9b3f-8191e56cf328",
    #       "owningInstitutionItemId": ".i240635085",
    body = {
      institution: "NYPL",
      holdingTransfers: [
        {
          source: {
            owningInstitutionBibId: '.b171339083',
            owningInstitutionHoldingsId: '9f8b5f99-0284-4c75-b637-b2d443839635-fladeedle'
          },
          destination: {
            owningInstitutionBibId: '.b147512797',
            owningInstitutionHoldingsId: '9f8b5f99-0284-4c75-b637-b2d443839635-fladeedle'
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Failed","holdingTransferResponses":[{"message":"Source and Destination holdings ids are not matching","holdingsTransferRequest":{"source":{"owningInstitutionBibId":".b171339083","owningInstitutionHoldingsId":"9f8b5f99-0284-4c75-b637-b2d443839635-fladeedle"},"destination":{"owningInstitutionBibId":".b147512797","owningInstitutionHoldingsId":"3dde1988-bf5a-4ecc-9b3f-8191e56cf328-fladeedle"}}}],"itemTransferResponses":[]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Failed')
    expect(record['holdingTransferResponses']).to be_a(Array)
    expect(record['holdingTransferResponses'].first).to be_a(Hash)
    expect(record['holdingTransferResponses'].first['message']).to eq('Source holdings is not under source bib')
  end

  it "54. Verify that if the user trying to transfer valid owning institution holding id details to existing bib id's,if that bib contains same owning institution holding id, then the application should display the appropriate error message.", number:54 do
    path = '/sharedCollection/transferHoldingsAndItems'
    # Attempt to transfer item 33433020333989 (and new holding id) into bib
    # b106067813, which currently has just item 33433004537811 under holding
    # 1fd04df8-995b-4d3d-a6c3-e917ef657389 . We expect this to fail because
    # we're assigning a holding id for the transferred record that already
    # exists under the destination bib
    body = {
      "institution":"NYPL","itemTransfers": [
        {
          "destination": {
            "owningInstitutionBibId":".b106067813",
            "owningInstitutionHoldingsId":"1fd04df8-995b-4d3d-a6c3-e917ef657389",
            "owningInstitutionItemId":".i101966908"
          },
          "source":{
            "owningInstitutionBibId":".b109358983",
            "owningInstitutionHoldingsId":"1506b70a-4f6a-4dd1-8b1b-55754d7f61c5",
            "owningInstitutionItemId":".i101966908"
          }
        }
      ]
    }

    body = {
      "institution":"NYPL","itemTransfers": [
        {
          "destination": {
            "owningInstitutionBibId":".b109358983",
            "owningInstitutionHoldingsId":"1506b70a-4f6a-4dd1-8b1b-55754d7f61c5",
            "owningInstitutionItemId":".i101966908"
          },
          "source":{
            "owningInstitutionBibId":".b106067813",
            "owningInstitutionHoldingsId":"1fd04df8-995b-4d3d-a6c3-e917ef657389",
            "owningInstitutionItemId":".i101966908"
          }
        }
      ]
    }
    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Failed","holdingTransferResponses":[{"message":"Source and Destination holdings ids are not matching","holdingsTransferRequest":{"source":{"owningInstitutionBibId":".b171339083","owningInstitutionHoldingsId":"9f8b5f99-0284-4c75-b637-b2d443839635-fladeedle"},"destination":{"owningInstitutionBibId":".b147512797","owningInstitutionHoldingsId":"3dde1988-bf5a-4ecc-9b3f-8191e56cf328-fladeedle"}}}],"itemTransferResponses":[]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Failed')
    expect(record['holdingTransferResponses']).to be_a(Array)
    expect(record['holdingTransferResponses'].first).to be_a(Hash)
    expect(record['holdingTransferResponses'].first['message']).to eq('Source holdings is not under source bib')
  end

  it "56. Verify that user can create an incomplete record by transfer api with new Bib and new Holding and existing item", number:56 do
    path = '/sharedCollection/transferHoldingsAndItems'
    # Attempt to transfer item 33333211202623 ...
    #       "owningInstitutionBibId": ".b171542186",
    #       "owningInstitutionHoldingsId": "40df42da-f873-435b-8fd7-3aed038b5e64",
    #       "owningInstitutionItemId": ".i207638627",
    # to new bib
    body = {
      institution: "NYPL",
      itemTransfers: [
        {
          source: {
            owningInstitutionBibId: '.b171542186',
            owningInstitutionHoldingsId: '40df42da-f873-435b-8fd7-3aed038b5e64',
            owningInstitutionItemId: '.i207638627'
          },
          destination: {
            owningInstitutionBibId: '.b1713390839999',
            owningInstitutionHoldingsId: '40df42da-f873-435b-8fd7-3aed038b5e64-9999',
            owningInstitutionItemId: '.i207638627'
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Success","holdingTransferResponses":[],"itemTransferResponses":[{"message":"Successfully relinked","itemTransferRequest":{"source":{"owningInstitutionBibId":".b171542186","owningInstitutionHoldingsId":"40df42da-f873-435b-8fd7-3aed038b5e64","owningInstitutionItemId":".i207638627"},"destination":{"owningInstitutionBibId":".b1713390839999","owningInstitutionHoldingsId":"40df42da-f873-435b-8fd7-3aed038b5e64-9999","owningInstitutionItemId":".i207638627"}}}]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Success')
    expect(record['itemTransferResponses']).to be_a(Array)
    expect(record['itemTransferResponses'].first).to be_a(Hash)
    expect(record['itemTransferResponses'].first['message']).to eq('Successfully relinked')
  end

  it "57. Verify that user can create dummy record through transfer api with existing Holding id or existing item id and new bib id.", number:57 do
    path = '/sharedCollection/transferHoldingsAndItems'
    # Attempt to transfer sole holding under b120785213 into new bib (to create dummy bib)
    body = {
      institution: "NYPL",
      holdingTransfers: [
        {
          source: {
            owningInstitutionBibId: '.b120785213999999',
            owningInstitutionHoldingsId: 'eddf2fa0-0ada-4438-b61b-55cd1f8d559b'
          },
          destination: {
            owningInstitutionBibId: '.b120785213',
            owningInstitutionHoldingsId: 'eddf2fa0-0ada-4438-b61b-55cd1f8d559b'
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Success","holdingTransferResponses":[{"message":"Successfully relinked","holdingsTransferRequest":{"source":{"owningInstitutionBibId":".b120785213","owningInstitutionHoldingsId":"eddf2fa0-0ada-4438-b61b-55cd1f8d559b"},"destination":{"owningInstitutionBibId":".b120785213999999","owningInstitutionHoldingsId":"eddf2fa0-0ada-4438-b61b-55cd1f8d559b"}}}],"itemTransferResponses":[]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Success')
    expect(record['holdingTransferResponses']).to be_a(Array)
    expect(record['holdingTransferResponses'].first).to be_a(Hash)
    expect(record['holdingTransferResponses'].first['message']).to eq('Successfully relinked')
  end
end
