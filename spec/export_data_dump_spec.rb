require_relative './spec_helper'

describe 'Export data dump' do

  before(:all) do
    # Update a single CUL item to ensure we have something to export:
    # update_item 'CUL', 'cul.CU54865638.marcxml'
  end

  it '1. Verify that Recap User can export PUL incremental data in Marc format', number:1 do

    response = get '/dataDump/exportDataDump?' + query_string({
      collectionGroupIds: '1,2',
      date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
      emailToAddress: nil,
      fetchType: 1,
      institutionCodes: 'PUL',
      outputFormat: 0,
      requestingInstitutionCode: 'NYPL',
      transmissionType: 1
    })

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^text\/plain/)

    records = parse_xml(response.body).xpath '/collection/record'

    Logger.debug "Got #{records.size} `/collection/record`s"

    expect(records.size).to be > 0

    records.each do |record|
      begin
        # https://www.oclc.org/bibformats/en/9xx/994.html
        institution = record.at_xpath('datafield[@tag=994]/subfield[@code="b"]').content
        expect(institution).to eq('PUL')
      rescue 
        puts '949$a not found'
      end
    end
  end

  it '2. Verify that Recap User can export CUL incremental data in Marc format', number:2 do
    response = get '/dataDump/exportDataDump?' + query_string({
      collectionGroupIds: '1,2',
      date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
      emailToAddress: nil,
      fetchType: 1,
      institutionCodes: 'CUL',
      outputFormat: 0,
      requestingInstitutionCode: 'NYPL',
      transmissionType: 1
    })

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^text\/plain/)

    records = parse_xml(response.body).xpath '/collection/record'

    Logger.debug "Got #{records.size} `/collection/record`s"

    expect(records.size).to be > 0
  end

  it '3. Verify that Recap User can export NYPL incremental data in Marc format', number:3 do
    response = get '/dataDump/exportDataDump?' + query_string({
      collectionGroupIds: '1,2',
      date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
      emailToAddress: nil,
      fetchType: 1,
      institutionCodes: 'NYPL',
      outputFormat: 0,
      requestingInstitutionCode: 'NYPL',
      transmissionType: 1
    })

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^text\/plain/)

    records = parse_xml(response.body).xpath '/collection/record'

    Logger.debug "Got #{records.size} `/collection/record`s"

    expect(records.size).to be > 0
  end

  it '4. Verify that Recap User can export PUL incremental data in SCSB format', number:4 do
    path = '/dataDump/exportDataDump?' + query_string({
      collectionGroupIds: '1,2',
      date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
      emailToAddress: nil,
      fetchType: 1,
      institutionCodes: 'PUL',
      outputFormat: 1,
      requestingInstitutionCode: 'NYPL',
      transmissionType: 1
    })
    response = get path

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^text\/plain/)

    records = parse_xml(response.body).xpath '/bibRecords/bibRecord'

    Logger.debug "Got #{records.size} `/bibRecords/bibRecord`s"

    expect(records.size).to be > 0
  end

  it '5. Verify that Recap User can export CUL incremental data in SCSB format', number:5 do
    response = get '/dataDump/exportDataDump?' + query_string({
      collectionGroupIds: '1,2',
      date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
      emailToAddress: nil,
      fetchType: 1,
      institutionCodes: 'CUL',
      outputFormat: 1,
      requestingInstitutionCode: 'NYPL',
      transmissionType: 1
    })

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^text\/plain/)

    records = parse_xml(response.body).xpath '/bibRecords/bibRecord'

    Logger.debug "Got #{records.size} `/bibRecords/bibRecord`s"

    expect(records.size).to be > 0
  end

  it '6. Verify that Recap User can export NYPL incremental data in SCSB format', number:6 do
    response = get '/dataDump/exportDataDump?' + query_string({
      collectionGroupIds: 1,
      date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
      emailToAddress: nil,
      fetchType: 1,
      institutionCodes: 'NYPL',
      outputFormat: 1,
      requestingInstitutionCode: 'NYPL',
      transmissionType: 1
    })

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^text\/plain/)

    records = parse_xml(response.body).xpath '/bibRecords/bibRecord'

    Logger.debug "Got #{records.size} `/bibRecords/bibRecord`s"

    expect(records.size).to be > 0
  end

  it '7. Verify that Recap User can export NYPL deleted data in SCSB format', number:7 do
    response = get '/dataDump/exportDataDump?' + query_string({
      date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
      emailToAddress: nil,
      fetchType: 2,
      institutionCodes: 'NYPL',
      outputFormat: 2,
      requestingInstitutionCode: 'NYPL',
      transmissionType: 1
    })

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^text\/plain/)

    records = JSON.parse response.body

    Logger.debug "Got #{records.size} records"

    expect(records.size).to be > 0
  end

  it '8. Verify that Recap User can export CUL deleted data in JSON format', number:8 do
    response = get '/dataDump/exportDataDump?' + query_string({
      date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
      emailToAddress: nil,
      fetchType: 2,
      institutionCodes: 'CUL',
      outputFormat: 2,
      requestingInstitutionCode: 'NYPL',
      transmissionType: 1
    })

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^text\/plain/)

    records = JSON.parse response.body

    Logger.debug "Got #{records.size} records"

    expect(records.size).to be > 0
  end

  it '9. Verify that Recap User can export PUL deleted data in JSON format', number:9 do
    response = get '/dataDump/exportDataDump?' + query_string({
      date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
      emailToAddress: nil,
      fetchType: 2,
      institutionCodes: 'PUL',
      outputFormat: 2,
      requestingInstitutionCode: 'NYPL',
      transmissionType: 1
    })

    expect(response.code.to_i).to eq(200)
    expect(response['Content-Type']).to match(/^text\/plain/)

    records = JSON.parse response.body

    Logger.debug "Got #{records.size} records"

    expect(records.size).to be > 0
  end

  describe 'export to date' do
    base_query = nil

    before(:each) do
      base_query = {
        date: (Time.new - 60*60*24*3).strftime('%Y-%m-%d %H:%M'),
        emailToAddress: nil,
        fetchType: 2,
        institutionCodes: 'PUL',
        outputFormat: 2,
        requestingInstitutionCode: 'NYPL',
        transmissionType: 1
      }
    end

    it '10. Verify that Recap User can export PUL data with datadump to date.', number:10 do
      response = get '/dataDump/exportDataDump?' + query_string({
        institutionCodes: 'PUL',
        toDate: (Time.new).strftime('%Y-%m-%d %H:%M'),
      }.merge(base_query))

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^text\/plain/)

      records = JSON.parse response.body

      Logger.debug "Got #{records.size} records"

      expect(records.size).to be > 0
    end

    it '11. Verify that Recap User can export CUL data with datadump to date.', number:11 do
      response = get '/dataDump/exportDataDump?' + query_string({
        institutionCodes: 'CUL',
        toDate: (Time.new).strftime('%Y-%m-%d %H:%M'),
      }.merge(base_query))

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^text\/plain/)

      records = JSON.parse response.body

      Logger.debug "Got #{records.size} records"

      expect(records.size).to be > 0
    end

    it '12. Verify that Recap User can export NYPL data with datadump to date.', number:12 do
      response = get '/dataDump/exportDataDump?' + query_string({
        institutionCodes: 'NYL',
        toDate: (Time.new).strftime('%Y-%m-%d %H:%M'),
      }.merge(base_query))

      expect(response.code.to_i).to eq(200)
      expect(response['Content-Type']).to match(/^text\/plain/)

      records = JSON.parse response.body

      Logger.debug "Got #{records.size} records"

      expect(records.size).to be > 0
    end
  end
end
