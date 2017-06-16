require "spec_helper"

RSpec.describe Ehsso::Person do
  it 'is creatable' do
    person = Ehsso::Person.new(id: 0, reference: '123', first_name: 'first_name', last_name: 'last_name', email: 'first_name.last_name@company.tld')

    expect(person.id).to eq(0)
    expect(person.reference).to eq('123')
    expect(person.first_name).to eq('first_name')
    expect(person.last_name).to eq('last_name')
    expect(person.email).to eq('first_name.last_name@company.tld')
    expect(person.full_name).to eq('last_name first_name')
  end

  it 'creates empty person instance' do
    person = Ehsso::Person.new

    expect(person.id).to eq(nil)
    expect(person.reference).to eq(nil)
    expect(person.first_name).to eq(nil)
    expect(person.last_name).to eq(nil)
    expect(person.email).to eq(nil)
    expect(person.full_name).to eq(nil)
  end

  it 'creates a person with reference only' do
    person = Ehsso::Person.new(reference: 'federro1')

    expect(person.id).to eq(nil)
    expect(person.reference).to eq('federro1')
    expect(person.first_name).to eq(nil)
    expect(person.last_name).to eq(nil)
    expect(person.email).to eq(nil)
    expect(person.full_name).to eq(nil)
  end

  context 'request header' do

    it 'fails to create a person with empty headers' do
      person = Ehsso::Person.parse_from_request_header({})
      expect(person).to eq(nil)
    end

    it 'creates a person with reference only' do
      person = Ehsso::Person.parse_from_request_header('HTTP_NIBR521' => 'FEDERRO1')
      expect(person).not_to be (nil)
      expect(person.id).to eq(nil)
      expect(person.reference).to eq('federro1')
      expect(person.first_name).to eq(nil)
      expect(person.last_name).to eq(nil)
      expect(person.email).to eq(nil)
    end

    it 'creates a person' do
      person = Ehsso::Person.parse_from_request_header('HTTP_NIBR521' => 'FEDERRO1', 'HTTP_NIBRFIRST' => 'Roger', 'HTTP_NIBRLAST' => 'Federer', 'HTTP_NIBREMAIL' => 'roger.federer@tennis.ch')
      expect(person).not_to be (nil)
      expect(person.id).to eq(nil)
      expect(person.reference).to eq('federro1')
      expect(person.first_name).to eq('Roger')
      expect(person.last_name).to eq('Federer')
      expect(person.email).to eq('roger.federer@tennis.ch')
      expect(person.full_name).to eq('Federer Roger')
    end

    it 'creates a person with empty first and last name' do
      person = Ehsso::Person.parse_from_request_header('HTTP_NIBR521' => 'FEDERRO1', 'HTTP_NIBRFIRST' => ' ', 'HTTP_NIBRLAST' => '', 'HTTP_NIBREMAIL' => '  ')
      expect(person).not_to be (nil)
      expect(person.id).to eq(nil)
      expect(person.reference).to eq('federro1')
      expect(person.first_name).to eq(nil)
      expect(person.last_name).to eq(nil)
      expect(person.email).to eq(nil)
      expect(person.full_name).to eq(nil)
    end

  end

  context 'payload' do

    before(:context) do
      Ehsso.configure do |config|
        # Application reference
        config.module_key = 'my_module_key'

        # Service Endpoint
        config.base_url   = "http://{host}:{port}"
      end
    end

    it 'creates payload' do
      person = Ehsso::Person.new(id: 0, reference: '123', first_name: 'first_name', last_name: 'last_name', email: 'first_name.last_name@company.tld')
      # call a private method to test
      payload = person.send(:payload)

      expect(payload.class).to eq(Hash)
      expect(payload[:type]).to eq('request')
      expect(payload[:action]).to eq('people.modules.roles')
      expect(payload[:request][0][:reference]).to eq('123')
      expect(payload[:request][0][:first_name]).to eq('first_name')
      expect(payload[:request][0][:last_name]).to eq('last_name')
      expect(payload[:request][0][:email]).to eq('first_name.last_name@company.tld')
      expect(payload[:request][0][:modules][0][:reference]).to eq('my_module_key')
    end
  end

  context 'service call' do
    before(:context) do
      Ehsso.configure do |config|
        # Application reference
        config.module_key = 'my_module_key'

        # Service Endpoint
        config.base_url   = "http://localhost:9999"
        config.username_and_password = "hello:world"
      end

    end

    it 'fails with fetch to invalid endpoint' do
      person = Ehsso::Person.new(reference: 'federro1')
      person.fetch
      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("http://localhost:9999/people: [0] Couldn't connect to server")
    end

    it 'fails with fetch_or_create to invalid endpoint' do
      person = Ehsso::Person.new(reference: 'federro1')
      person.fetch
      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("http://localhost:9999/people: [0] Couldn't connect to server")
    end

    it 'handles a valid service call' do
      person = Ehsso::Person.new(reference: 'federro1')
      person.send(:handle_service_call, { action: 'people.modules.roles', service_class: ServiceOk })

      expect(person.valid?).to eq(true)
      expect(person.first_name).to eq('Roger')
      expect(person.last_name).to eq('Federer')
      expect(person.email).to eq('roger.federer@tennis.ch')
      expect(person.guest?).to eq(true)
      expect(person.user?).to eq(true)
      expect(person.operator?).to eq(true)
      expect(person.administrator?).to eq(true)
    end

    it 'fails with not found person reference' do
      person = Ehsso::Person.new(reference: 'federro1')
      person.send(:handle_service_call, { action: 'people.modules.roles', service_class: ServiceNotFound })

      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq('person not found')
    end

    it 'fails with 200 code but invalid json' do
      person = Ehsso::Person.new(reference: 'federro1')
      person.send(:handle_service_call, { action: 'people.modules.roles', service_class: ServiceOkJsonIssue })

      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq('Unable to parse service response data')
    end

    it 'fails with error code and invalid json' do
      person = Ehsso::Person.new(reference: 'federro1')
      person.send(:handle_service_call, { action: 'people.modules.roles', service_class: Service500JsonIssue })

      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq('https://localhost:9999/people: [500] just a simple message')
    end
  end

  context 'roles' do
    it 'validates roles' do
      person = Ehsso::Person.new(roles: ['GUEST', 'USER'])
      expect(person.guest?).to eq(true)
      expect(person.user?).to eq(true)
      expect(person.operator?).to eq(false)
    end

    it 'fails with invalid method' do
      person = Ehsso::Person.new(roles: ['GUEST', 'USER'])
      expect {
        person.unknown
      }.to raise_error(RuntimeError, "Method [unknown] not defined or allowed")
    end
  end

end
