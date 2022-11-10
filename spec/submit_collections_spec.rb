require_relative './spec_helper'

describe 'SubmitCollections' do
  it '6. Verify that the bib/holding/item metadata can be updated through the API, for a given item.', number:6 do
    barcode = '33433034009526'

    path = '/sharedCollection/submitCollection?institution=NYPL&isCGDProtected=false'

    # Following was generated in QA via recap/nypl-bibs?barcode=33433034009526&customerCode=NA
    doc = parse_xml File.open("./spec/data/nypl-#{barcode}.scsbxml").read
    title_node = doc.at_xpath('//datafield[@tag="245"]/subfield[@code="a"]')
    # Edit title:
    original_title = title_node.content
    author = doc.at_xpath('//datafield[@tag="245"]/subfield[@code="c"]').content
    title_node.content += ' (Edited)'
    body = doc.to_s

    response = post path, body

    expect(response.code.to_i).to eq(200)
    # This is the required Content-Type even though we're sending XML:
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. [{"itemBarcode"=>"33433034009526", "message"=>"Success record"}]

    expect(record).to be_a(Array)
    expect(record.size).to eq(1)
    expect(record.first).to be_a(Hash)
    expect(record.first['itemBarcode']).to eq(barcode)
    expect(record.first['message']).to eq('Success record')

    Logger.debug "# Verifying title updated"
    item = item_by_barcode(barcode)
    expect(item).to be_a(Hash)
    expect(item['barcode']).to eq(barcode)
    expect(item['title']).to eq("#{title_node.content} #{author}")

    Logger.debug "# Reverting doc to original"
    body = File.open("./spec/data/nypl-#{barcode}.scsbxml").read
    response = post path, body

    Logger.debug "# Verifying title reverted"
    item = item_by_barcode(barcode)
    expect(item).to be_a(Hash)
    expect(item['barcode']).to eq(barcode)
    expect(item['title']).to eq("#{original_title} #{author}")
  end

  it '7. Verify that when barcode is invalid the exception is returned.', number:7 do
    path = '/sharedCollection/submitCollection?institution=NYPL&isCGDProtected=false'
    # Following was generated in QA via recap/nypl-bibs?barcode=33433034009526&customerCode=NA
    body = File.open('./spec/data/nypl-33433034009526.scsbxml').read

    # Change barcode to something invalid:
    body = body.gsub '33433034009526', '3343303400952699999'

    response = post path, body

    expect(response.code.to_i).to eq(200)
    # This is the required Content-Type even though we're sending XML:
    expect(response['Content-Type']).to match(/^application\/json/)

    record = JSON.parse response.body

    # e.g. [{"itemBarcode":"3343303400952699999","message":"Exception record - Item is unavailable in scsb to update"}]

    expect(record).to be_a(Array)
    expect(record.size).to eq(1)
    expect(record.first).to be_a(Hash)
    expect(record.first['itemBarcode']).to eq('3343303400952699999')
    expect(record.first['message']).to eq('Exception record - Item is unavailable in scsb to update')
  end
end
