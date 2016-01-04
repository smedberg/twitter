require 'helper'

describe Twitter::REST::Request do
  before do
    @client = Twitter::REST::Client.new(consumer_key: 'CK', consumer_secret: 'CS', access_token: 'AT', access_token_secret: 'AS')
  end

  describe '#request' do
    it 'encodes the entire body when no uploaded media is present' do
      stub_post('/1.1/statuses/update.json').with(body: {status: 'Update'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
      @client.update('Update')
      expect(a_post('/1.1/statuses/update.json').with(body: {status: 'Update'})).to have_been_made
    end
    it 'encodes none of the body when uploaded media is present' do
      stub_request(:post, 'https://upload.twitter.com/1.1/media/upload.json').to_return(body: fixture('upload.json'), headers: {content_type: 'application/json; charset=utf-8'})
      stub_post('/1.1/statuses/update.json').with(body: {status: 'Update', media_ids: '470030289822314497'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
      @client.update_with_media('Update', fixture('pbjt.gif'))
      expect(a_request(:post, 'https://upload.twitter.com/1.1/media/upload.json')).to have_been_made
      expect(a_post('/1.1/statuses/update.json').with(body: {status: 'Update', media_ids: '470030289822314497'})).to have_been_made
    end

    context 'when using a proxy' do
      before do
        @client = Twitter::REST::Client.new(consumer_key: 'CK', consumer_secret: 'CS', access_token: 'AT', access_token_secret: 'AS', proxy: {host: '127.0.0.1', port: 3328})
      end
      it 'requests via the proxy when no uploaded media is present' do
        stub_post('/1.1/statuses/update.json').with(body: {status: 'Update'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
        expect(HTTP).to receive(:via).with('127.0.0.1', 3328).and_call_original
        @client.update('Update')
      end
      it 'requests via the proxy when uploaded media is present' do
        stub_request(:post, 'https://upload.twitter.com/1.1/media/upload.json').to_return(body: fixture('upload.json'), headers: {content_type: 'application/json; charset=utf-8'})
        stub_post('/1.1/statuses/update.json').with(body: {status: 'Update', media_ids: '470030289822314497'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
        expect(HTTP).to receive(:via).with('127.0.0.1', 3328).twice.and_call_original
        @client.update_with_media('Update', fixture('pbjt.gif'))
      end

      context 'when using global timeout' do
        it 'passes timeout options to HTTP' do
          stub_post('/1.1/statuses/update.json').with(body: {status: 'Update'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
          expect(HTTP).to receive(:via).with('127.0.0.1', 3328).and_return(HTTP)
          expect(HTTP).to receive(:timeout).with(:global, connect: 1, read: 2, write: 3).and_call_original
          @client.update('Update', global_timeout: {connect: 1, read: 2, write: 3})
        end
      end

      context 'when using per-operation timeout' do
        it 'passes timeout options to HTTP' do
          stub_post('/1.1/statuses/update.json').with(body: {status: 'Update'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
          expect(HTTP).to receive(:via).with('127.0.0.1', 3328).and_return(HTTP)
          expect(HTTP).to receive(:timeout).with(:per_operation, connect: 3, read: 2, write: 1).and_call_original
          @client.update('Update', per_operation_timeout: {connect: 3, read: 2, write: 1})
        end
      end
    end

    context 'when using global timeout' do
      it 'passes timeout options to HTTP' do
        stub_post('/1.1/statuses/update.json').with(body: {status: 'Update'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
        expect(HTTP).to receive(:timeout).with(:global, connect: 1, read: 2, write: 3).and_call_original
        @client.update('Update', global_timeout: {connect: 1, read: 2, write: 3})
      end

      it 'does not pass timeout info to Twitter::Headers' do
        headers = {test: 'result'}
        headers_stub = double('headers')
        allow(headers_stub).to receive_messages(request_headers: headers)
        expect(Twitter::Headers).to receive(:new).with(@client, :post, Addressable::URI.new(scheme: 'https', host: 'api.twitter.com', path: '/1.1/statuses/update.json'), status: 'Update').and_return(headers_stub)
        stub_post('/1.1/statuses/update.json').with(headers: headers, body: {status: 'Update'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
        @client.update('Update', global_timeout: {connect: 1, read: 2, write: 3})
      end
    end

    context 'when using per-operation timeout' do
      it 'passes timeout options to HTTP' do
        stub_post('/1.1/statuses/update.json').with(body: {status: 'Update'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
        expect(HTTP).to receive(:timeout).with(:per_operation, connect: 3, read: 2, write: 1).and_call_original
        @client.update('Update', per_operation_timeout: {connect: 3, read: 2, write: 1})
      end

      it 'does not pass timeout info to Twitter::Headers' do
        headers = {test: 'result'}
        headers_stub = double('headers')
        allow(headers_stub).to receive_messages(request_headers: headers)
        expect(Twitter::Headers).to receive(:new).with(@client, :post, Addressable::URI.new(scheme: 'https', host: 'api.twitter.com', path: '/1.1/statuses/update.json'), status: 'Update').and_return(headers_stub)
        stub_post('/1.1/statuses/update.json').with(headers: headers, body: {status: 'Update'}).to_return(body: fixture('status.json'), headers: {content_type: 'application/json; charset=utf-8'})
        @client.update('Update', per_operation_timeout: {connect: 3, read: 2, write: 1})
      end
    end
  end
end
