require_relative './spec_helper'

describe 'Search' do
  describe '2. Verify that the search API returns the expected items.', number:2 do
    it "search by various criteria" do
      [
        {
          query: {
            fieldValue: '0713998067',
            fieldName: 'ISBN',
            owningInstitutions: ['PUL', 'CUL', 'NYPL', 'HL']
          },
          target: {
            barcode: 'CU74585878'
          }
        },
        {
          query: {
            fieldValue: 'CU75061864',
            fieldName: 'Barcode',
            owningInstitutions: ['CUL']
          },
          target: {
            barcode: 'CU75061864'
          }
        },
        {
          query: {
            fieldValue: 'HX295W',
            fieldName: 'Barcode',
            owningInstitutions: ['HL']
          },
          target: {
            barcode: 'HX295W',
          }
        },
        {
          query: {
            fieldValue: '32101099217760',
            fieldName: 'Barcode',
            owningInstitutions: ['PUL']
          },
          target: {
            barcode: '32101099217760',
          }
        },
        {
          query: {
            fieldValue: '33433034659452',
            fieldName: 'Barcode',
            owningInstitutions: ['NYPL']
          },
          target: {
            barcode: '33433034659452'
          }
        },
        {
          query: {
            fieldValue: '33433034659452',
            fieldName: 'Barcode',
            owningInstitutions: ['CUL']
          },
          target: nil
        }
      ].each do |expectation|
      query = expectation[:query]
      target = expectation[:target]

        path = '/searchService/search'

        Logger.debug "______________________________________________"
        Logger.debug "Querying #{query[:fieldName]} #{query[:fieldValue]} (OI #{query[:owningInstitutions].join(',')})"
        body = {
          "deleted": false,
          "fieldValue": query[:fieldValue],
          "fieldName": query[:fieldName],
          "owningInstitutions": query[:owningInstitutions]
        }

        response = post path, body

        expect(response.code.to_i).to eq(200)
        expect(response['Content-Type']).to match(/^application\/json/)

        record = JSON.parse response.body
        expect(record).to be_a(Hash)
        expect(record["searchResultRows"]).to be_a(Array)

        if (target.nil?)
          expect(record["searchResultRows"]).to be_empty
          Logger.debug "Found 0 results as expected"
        else
          expect(record["searchResultRows"].first).to be_a(Hash)
          # Expect match to have an OI that agrees with query:
          expect(query[:owningInstitutions]).to include(record["searchResultRows"].first["owningInstitution"])
          expect(record["searchResultRows"].first["barcode"]).to eq(target[:barcode])

          Logger.debug "Found #{target[:barcode]} in response\n"
        end
      end
    end
  end

  describe '3. Verify that the search API returns the expected items for barcodes with newer CGDs', number:3 do
    it "search by various criteria" do
      [
        {
          query: {
            fieldValue: 'HY32T6',
            fieldName: 'Barcode',
            owningInstitutions: ['HL']
          },
          target: {
            barcode: 'HY32T6',
            collectionGroupDesignation: 'Uncommittable'
          }
        }
      ].each do |expectation|

      query = expectation[:query]
      target = expectation[:target]

        path = '/searchService/search'

        Logger.debug "______________________________________________"
        Logger.debug "Querying #{query[:fieldName]} #{query[:fieldValue]} (OI #{query[:owningInstitutions].join(',')})"
        body = {
          "deleted": false,
          "fieldValue": query[:fieldValue],
          "fieldName": query[:fieldName],
          "owningInstitutions": query[:owningInstitutions]
        }

        response = post path, body

        expect(response.code.to_i).to eq(200)
        expect(response['Content-Type']).to match(/^application\/json/)

        record = JSON.parse response.body
        expect(record).to be_a(Hash)
        expect(record["searchResultRows"]).to be_a(Array)

        if (target.nil?)
          expect(record["searchResultRows"]).to be_empty
          Logger.debug "Found 0 results as expected"
        else
          expect(record["searchResultRows"].first).to be_a(Hash)
          # Expect match to have an OI that agrees with query:
          expect(query[:owningInstitutions]).to include(record["searchResultRows"].first["owningInstitution"])
          expect(record["searchResultRows"].first["barcode"]).to eq(target[:barcode])

          Logger.debug "Found #{target[:barcode]} in response"
        end
      end
    end
  end
end
