require 'spec_helper'

describe MarketingCloudSDK::Soap do

  let(:client) { MarketingCloudSDK::Client.new }

  subject { client }

  it { should respond_to(:soap_get) }
  it { should respond_to(:soap_post) }
  it { should respond_to(:soap_patch) }
  it { should respond_to(:soap_delete) }
  it { should respond_to(:soap_describe) }

  it { should respond_to(:header) }
  it { should_not respond_to(:header=) }

  it { should respond_to(:wsdl) }
  it { should respond_to(:wsdl=) }

  it { should respond_to(:endpoint) }
  it { should_not respond_to(:endpoint=) }

  it { should respond_to(:soap_client) }

  it { should respond_to(:package_name) }
  it { should respond_to(:package_name=) }

  it { should respond_to(:package_folders) }
  it { should respond_to(:package_folders=) }

  its(:debug) { should be_falsy }
  its(:wsdl) { should eq 'https://webservice.exacttarget.com/etframework.wsdl' }

  describe '#header' do
    it 'raises an exception when internal_token is missing' do
      expect { client.header }.to raise_exception 'Require legacy token for soap header'
    end

    it 'returns header hash' do
      client.internal_token = 'innerspace'
      expect(client.header).to eq(
        {
          'oAuth' => {
            :@xmlns => 'http://exacttarget.com',
            'oAuthToken' => 'innerspace'
          }
        }
      )
    end
  end

  describe 'requests' do
    subject do
      client.stub(:soap_request) do |action, message|
        [action, message]
      end
      client
    end

    it '#soap_describe calls client with :describe and DescribeRequests message' do
      expect(subject.soap_describe 'Subscriber').to eq(
        [:describe, {'DescribeRequests' => {'ObjectDefinitionRequest' => {'ObjectType' => 'Subscriber' }}}]
      )
    end

    describe '#soap_post' do
      let(:properties) do
        [
          {
            'Objects' => [{
              'EmailAddress' => 'test@fuelsdk.com',
              'Attributes' => [
                {'Name' => 'First Name', 'Value' => 'first'},
                {'Name' => 'Last Name', 'Value' => 'subscriber'},
              ],
              :'@xsi:type' => 'tns:Subscriber'
            }]
          }
        ]
      end

      it 'formats a soap :create message using the provided properties' do
        expect(subject.soap_post('Subscriber', properties)).to eq([
          :create,
          {
            "Objects" => [
              {
                "Objects" => [
                  {
                    "EmailAddress" => "test@fuelsdk.com",
                    "Attributes" => [
                      {"Name" => "First Name", "Value" => "first"},
                      {"Name" => "Last Name", "Value" => "subscriber"}
                    ],
                    :"@xsi:type" => "tns:Subscriber"
                  }
                ],
                :"@xsi:type" => "tns:Subscriber"
              }
            ]
          }
        ])
      end
    end
  end
end
