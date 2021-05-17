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
    # to bib with two existing items under same holding:
    #       "owningInstitutionBibId": ".b196813153",
    #       items:
    #        1.
    #          "owningInstitutionItemId": ".i172423314",
    #          "owningInstitutionHoldingsId": "2f9c2154-d9b6-4960-be2c-5c34a308fde9"
    #        2.#
    #          "owningInstitutionItemId": ".i305902581",
    #          "owningInstitutionHoldingsId": "2f9c2154-d9b6-4960-be2c-5c34a308fde9"
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
            owningInstitutionBibId: '.b196813153',
            owningInstitutionHoldingsId: '2f9c2154-d9b6-4960-be2c-5c34a308fde9',
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

    barcode = '33433066644109'

    Logger.debug "# Verifying item moved"

    item = item_by_barcode(barcode)

    expect(item).to be_a(Hash)
    expect(item['owningInstitutionHoldingsId']).to eq(body[:itemTransfers].first[:destination][:owningInstitutionHoldingsId])
    expect(item['owningInstitutionBibId']).to eq(body[:itemTransfers].first[:destination][:owningInstitutionBibId])

    Logger.debug "# Reverting"

    revert_body = {
      institution: "NYPL",
      itemTransfers: [
        {
          source: {
            owningInstitutionBibId: body[:itemTransfers].first[:destination][:owningInstitutionBibId],
            owningInstitutionHoldingsId: body[:itemTransfers].first[:destination][:owningInstitutionHoldingsId],
            owningInstitutionItemId: '.i168151662'
          },
          destination: {
            owningInstitutionBibId: body[:itemTransfers].first[:source][:owningInstitutionBibId],
            owningInstitutionHoldingsId: body[:itemTransfers].first[:source][:owningInstitutionHoldingsId],
            owningInstitutionItemId: '.i168151662'
          }
        }
      ]
    }
   
    response = post path, revert_body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Success","holdingTransferResponses":[],"itemTransferResponses":[{"message":"Successfully relinked","itemTransferRequest":{"source":{"owningInstitutionBibId":".b131115674","owningInstitutionHoldingsId":"ef24b823-aaf0-4b1c-8750-f55760979017","owningInstitutionItemId":".i168151662"},"destination":{"owningInstitutionBibId":".b131115674","owningInstitutionHoldingsId":"c8e2a497-1a8f-46ac-8ebc-2e0004657690","owningInstitutionItemId":".i168151662"}}}]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Success')

    Logger.debug "# Verifying Reverted"

    item = item_by_barcode(barcode)

    expect(item).to be_a(Hash)
    expect(item['owningInstitutionHoldingsId']).to eq(body[:itemTransfers].first[:source][:owningInstitutionHoldingsId])
    expect(item['owningInstitutionBibId']).to eq(body[:itemTransfers].first[:source][:owningInstitutionBibId])
  end

  it "46. Verify that user can't transfer the item or Holding id information for cross-institution BIB ids.", number:46 do
    path = '/sharedCollection/transferHoldingsAndItems'

    # These may need to be changed to a barcode that can be transferred and a
    # partner bnum that could in principle be transferred into (if it weren't
    # cross-institution)
    barcode = '33333068015888'
    destination_bnum = '2802952'

    item = item_by_barcode barcode

    destination_items = items_by_bnum destination_bnum, institution: 'CUL'
    destination_holding = destination_items.first['owningInstitutionHoldingsId']

    Logger.debug "# Transferring #{barcode} into bib #{destination_bnum} (holding #{destination_holding})"

    body = {
      institution: "NYPL",
      itemTransfers: [
        {
          source: {
            owningInstitutionBibId: item['owningInstitutionBibId'],
            owningInstitutionHoldingsId: item['owningInstitutionHoldingsId'],
            owningInstitutionItemId: item['owningInstitutionItemId']
          },
          destination: {
            owningInstitutionBibId: destination_bnum,
            owningInstitutionHoldingsId: destination_holding,
            owningInstitutionItemId: item['owningInstitutionItemId']
          }
        }
      ]
    }
    p body
    raise 'done'

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

    # These may need to be changed to a barcode that can be transferred and a
    # bnum that can be transferred into..
    barcode = '33433116343660'
    destination_bnum = '.b144492477'

    item = item_by_barcode barcode

    body = {
      institution: "NYPL",
      holdingTransfers: [
        {
          source: {
            owningInstitutionBibId: item['owningInstitutionBibId'],
            owningInstitutionHoldingsId: item['owningInstitutionHoldingsId']
          },
          destination: {
            owningInstitutionBibId: destination_bnum,
            owningInstitutionHoldingsId: item['owningInstitutionHoldingsId']
          }
        }
      ]
    }

    Logger.debug "# Transferring #{barcode} and its holding (#{item['owningInstitutionHoldingsId']}) into bib #{destination_bnum}"

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

    Logger.debug "# Verifying transfer"

    moved_item = item_by_barcode barcode

    expect(moved_item).to be_a(Hash)
    expect(moved_item['owningInstitutionHoldingsId']).to eq(body[:holdingTransfers].first[:destination][:owningInstitutionHoldingsId])
    expect(moved_item['owningInstitutionBibId']).to eq(body[:holdingTransfers].first[:destination][:owningInstitutionBibId])

=begin
    # Note: This doesn't actually work. Once an item has been moved out of a
    # bib, if there are no other items in that bib, the bib is deaccessioned
    # and I don't believe there's a way to undo that from our end.
    Logger.debug "# Reverting transfer"

    revert_body = {
      institution: "NYPL",
      holdingTransfers: [
        {
          source: {
            owningInstitutionBibId: body[:holdingTransfers].first[:destination][:owningInstitutionBibId],
            owningInstitutionHoldingsId: body[:holdingTransfers].first[:destination][:owningInstitutionHoldingsId]
          },
          destination: {
            owningInstitutionBibId: body[:holdingTransfers].first[:source][:owningInstitutionBibId],
            owningInstitutionHoldingsId: body[:holdingTransfers].first[:source][:owningInstitutionHoldingsId]
          }
        }
      ]
    }

    response = post path, revert_body
    record = JSON.parse response.body

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Success')
    expect(record['holdingTransferResponses']).to be_a(Array)
    expect(record['holdingTransferResponses'].first).to be_a(Hash)
    expect(record['holdingTransferResponses'].first['message']).to eq('Successfully relinked')
=end
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

    # Note: The following barcode and destination_bib params may need to be
    # changed to identify an item that can be moved and a bib that has at least
    # one item, respectively.
    barcode = '33433121476331'
    destination_bib = '.b109358983'

    item = item_by_barcode barcode

    destination_bib_items = items_by_bnum destination_bib

    # Attempt to transfer holding into a different bib, but specify that the item be placed
    # in a holding id that already exists in that bib, so we expect a
    # rejection.

    path = '/sharedCollection/transferHoldingsAndItems'
    body = {
      "institution":"NYPL",
      "holdingTransfers": [
        {
          "source": {
            "owningInstitutionBibId": item['owningInstitutionBibId'],
            "owningInstitutionHoldingsId": item['owningInstitutionHoldingsId']
          },
          "destination": {
            "owningInstitutionBibId": destination_bib,
            "owningInstitutionHoldingsId": destination_bib_items.first['owningInstitutionHoldingsId']
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Failed","holdingTransferResponses":[{"message":"Source and Destination holdings ids are not matching","holdingsTransferRequest":{"source":{"owningInstitutionBibId":".b213118142","owningInstitutionHoldingsId":"6985136c-39a5-42ff-8fc9-a303b9e468aa"},"destination":{"owningInstitutionBibId":".b109358983","owningInstitutionHoldingsId":"1506b70a-4f6a-4dd1-8b1b-55754d7f61c5"}}}],"itemTransferResponses":[]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Failed')
    expect(record['holdingTransferResponses']).to be_a(Array)
    expect(record['holdingTransferResponses'].first).to be_a(Hash)
    expect(record['holdingTransferResponses'].first['message']).to eq('Source holdings is not under source bib')
  end

  it "55. Verify that if the user trying to transfer new owning institution holding id details to existing bib id's, then the application should display the appropriate error message.", number:55 do
    barcode = '33433101862419'
    destination_bib = '.b109358983'

    item = item_by_barcode barcode

    # Attempt to transfer new holding id into a valid bib
 
    source_holdings_id = item['owningInstitutionHoldingsId'] + '-999'
    Logger.debug "Attempting to transfer #{source_holdings_id} (which doesn't exist) into #{destination_bib} (which does)"

    path = '/sharedCollection/transferHoldingsAndItems'
    body = {
      "institution":"NYPL",
      "holdingTransfers": [
        {
          "source": {
            "owningInstitutionBibId": item['owningInstitutionBibId'],
            "owningInstitutionHoldingsId": source_holdings_id 
          },
          "destination": {
            "owningInstitutionBibId": destination_bib,
            "owningInstitutionHoldingsId": source_holdings_id
          }
        }
      ]
    }

    response = post path, body

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. {"message":"Failed","holdingTransferResponses":[{"message":"Source and Destination holdings ids are not matching","holdingsTransferRequest":{"source":{"owningInstitutionBibId":".b13703698x","owningInstitutionHoldingsId":"150304f8-d6b1-488f-9b9d-56786d9ac433-999"},"destination":{"owningInstitutionBibId":".b109358983","owningInstitutionHoldingsId":"1506b70a-4f6a-4dd1-8b1b-55754d7f61c5"}}}],"itemTransferResponses":[]}

    expect(record).to be_a(Hash)
    expect(record['message']).to eq('Failed')
    expect(record['holdingTransferResponses']).to be_a(Array)
    expect(record['holdingTransferResponses'].first).to be_a(Hash)
    expect(record['holdingTransferResponses'].first['message']).to eq('Source holdings is not under source bib')
  end

  it "56. Verify that user can create an incomplete record by transfer api with new Bib and new Holding and existing item", number:56 do

    # This may need to be changed to a barcode that can be transferred
    barcode = '33333211202623'

    Logger.debug "Looking up details for item #{barcode}"

    item = item_by_barcode barcode
    destination_bib_id = item['owningInstitutionBibId'] + '-new'
    destination_holdings_id = item['owningInstitutionHoldingsId'] + '-new'

    Logger.debug "# Transferring #{barcode} into new bib (#{destination_bib_id}) and holding (#{destination_holdings_id})"

    path = '/sharedCollection/transferHoldingsAndItems'
    body = {
      institution: "NYPL",
      itemTransfers: [
        {
          source: {
            owningInstitutionBibId: item['owningInstitutionBibId'],
            owningInstitutionHoldingsId: item['owningInstitutionHoldingsId'],
            owningInstitutionItemId: item['owningInstitutionItemId']
          },
          destination: {
            owningInstitutionBibId: destination_bib_id,
            owningInstitutionHoldingsId: destination_holdings_id,
            owningInstitutionItemId: item['owningInstitutionItemId']
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

    Logger.debug "# Verifying transfer"

    moved_item = item_by_barcode barcode

    expect(moved_item).to be_a(Hash)
    expect(moved_item['owningInstitutionHoldingsId']).to eq(body[:itemTransfers].first[:destination][:owningInstitutionHoldingsId])
    expect(moved_item['owningInstitutionBibId']).to eq(body[:itemTransfers].first[:destination][:owningInstitutionBibId])
  end

  it "57. Verify that user can create dummy record through transfer api with existing Holding id or existing item id and new bib id.", number:57 do
    # This may need to be changed to a barcode that can be transferred
    barcode = '33433032580189'

    Logger.debug "Looking up details for item #{barcode}"

    item = item_by_barcode barcode
    destination_bib_id = item['owningInstitutionBibId'] + '-new'

    Logger.debug "# Transferring #{barcode} into new bib (#{destination_bib_id}) and same holding (#{item['owningInstitutionHoldingsId']})"

    path = '/sharedCollection/transferHoldingsAndItems'
    body = {
      institution: "NYPL",
      holdingTransfers: [
        {
          source: {
            owningInstitutionBibId: item['owningInstitutionBibId'],
            owningInstitutionHoldingsId: item['owningInstitutionHoldingsId']
          },
          destination: {
            owningInstitutionBibId: destination_bib_id,
            owningInstitutionHoldingsId: item['owningInstitutionHoldingsId']
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

  it "58. Verify that user can transfer holding or item id's for bound with records", number:58 do
    # This may need to be changed to a barcode that can be transferred
    #  e.g. 
    #    33433011646076
    #    33433011646068
    #    33433011646050
    #    33433011646043
    #    33433011646035
    barcode = '33433011646050'
    destination_bib_id = '.b164727711'

    Logger.debug "Looking up details for item #{barcode}"

    item = item_by_barcode barcode
    expect(item).to be_a(Hash)

    holdings_id = item['owningInstitutionHoldingsId'] || item['searchItemResultRows'].first['owningInstitutionHoldingsId']
    Logger.debug "# Transferring #{barcode} into bib (#{destination_bib_id}) with same holding (#{holdings_id})"

    path = '/sharedCollection/transferHoldingsAndItems'
    body = {
      institution: "NYPL",
      holdingTransfers: [
        {
          source: {
            owningInstitutionBibId: item['owningInstitutionBibId'],
            owningInstitutionHoldingsId: holdings_id
          },
          destination: {
            owningInstitutionBibId: destination_bib_id,
            owningInstitutionHoldingsId: holdings_id
          }
        }
      ]
    }

    response = post path, body
    p body
    raise 'done'

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

  it "59. Verify that user view in search UI for orphan bibs and holdings and they will be soft deleted.", number:59 do
    # This may need to be changed to a barcode that is a bound with where one of its bibs is *only* linked to the item
    barcode = '33433011646043'
    destination_bib_id = '.b144301295'

    Logger.debug "Looking up details for item #{barcode}"
    item = item_by_barcode barcode
    expect(item).to be_a(Hash)

    Logger.debug "Verifying item is a bound with"
    bnums = bnums_by_barcode barcode
    expect(bnums.size).to be > 1

    holdings_id = item['owningInstitutionHoldingsId'] || item['searchItemResultRows'].first['owningInstitutionHoldingsId']
    Logger.debug "# Transferring #{barcode} into bib (#{destination_bib_id}) with same holding (#{holdings_id})"

    bnum_we_expect_to_be_deleted = bnums
      .map { |bnum| ( { bnum: bnum, barcodes: items_by_bnum(bnum).map { |item| item['barcode'] } }) }
      # .filter { |barcodes| barcodes[:barcodes].size == 1 }
      # .map { |barcodes| barcodes[:bnum] }
    puts "Bnum we expect to be soft deleted: #{bnum_we_expect_to_be_deleted}"

    path = '/sharedCollection/transferHoldingsAndItems'
    body = {
      institution: "NYPL",
      holdingTransfers: [
        {
          source: {
            owningInstitutionBibId: item['owningInstitutionBibId'],
            owningInstitutionHoldingsId: holdings_id
          },
          destination: {
            owningInstitutionBibId: destination_bib_id,
            owningInstitutionHoldingsId: holdings_id
          }
        }
      ]
    }

    p body
    raise 'done'
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
