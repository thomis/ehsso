require "spec_helper"
require "yaml"

RSpec.describe Ehsso::Person do
  it "is creates a user without role" do
    person = described_class.new(id: 0, reference: "123", first_name: "first_name", last_name: "last_name", email: "first_name.last_name@company.tld")

    expect(person.id).to eq(0)
    expect(person.reference).to eq("123")
    expect(person.first_name).to eq("first_name")
    expect(person.last_name).to eq("last_name")
    expect(person.email).to eq("first_name.last_name@company.tld")
    expect(person.full_name).to eq("last_name first_name")
    expect(person.roles).to be_empty
  end

  it "is creates a user with role" do
    person = described_class.new(
      id: 0,
      reference: "123",
      first_name: "first_name",
      last_name: "last_name",
      email: "first_name.last_name@company.tld",
      roles: ["ADMIN"]
    )

    expect(person.id).to eq(0)
    expect(person.reference).to eq("123")
    expect(person.first_name).to eq("first_name")
    expect(person.last_name).to eq("last_name")
    expect(person.email).to eq("first_name.last_name@company.tld")
    expect(person.full_name).to eq("last_name first_name")
    expect(person.roles).to eq(["ADMIN"])
  end

  it "creates empty person instance" do
    person = described_class.new

    expect(person.id).to eq(nil)
    expect(person.reference).to eq(nil)
    expect(person.first_name).to eq(nil)
    expect(person.last_name).to eq(nil)
    expect(person.email).to eq(nil)
    expect(person.full_name).to eq(nil)
  end

  it "creates a person with reference only" do
    person = Ehsso::Person.new(reference: "federro1")

    expect(person.id).to eq(nil)
    expect(person.reference).to eq("federro1")
    expect(person.first_name).to eq(nil)
    expect(person.last_name).to eq(nil)
    expect(person.email).to eq(nil)
    expect(person.full_name).to eq(nil)
  end

  context "request header" do
    it "failes to create a valid person with wrong header type" do
      person = described_class.parse_from_request_header("dfasf")
      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("Unable to extract HTTP_NIBR* properties from request header")
    end

    it "fails to create a person with empty headers" do
      person = described_class.parse_from_request_header({})
      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("Unable to extract HTTP_NIBR* properties from request header")
    end

    it "fails to create a person if reference contains only spaces" do
      person = described_class.parse_from_request_header(
        "HTTP_NIBR521" => "   ",
        "HTTP_NIBRFIRST" => nil,
        "HTTP_NIBREMAIL" => nil
      )
      expect(person.valid?).to be_falsy
      expect(person.last_error_message).to eq("Unable to extract HTTP_NIBR* properties from request header")
    end

    it "create a person correctly if reference contains spaces" do
      person = described_class.parse_from_request_header("HTTP_NIBR521" => "      FEDERRO1     ")
      expect(person.id).to be_nil
      expect(person.reference).to eq("federro1")
    end

    it "strips spaces around first name, last name and email" do
      person = described_class.parse_from_request_header(
        "HTTP_NIBR521" => "FEDERRO1",
        "HTTP_NIBRFIRST" => "  Roger ",
        "HTTP_NIBRLAST" => " Federer  ",
        "HTTP_NIBREMAIL" => "  roger.federer@tennis.ch  "
      )
      expect(person.first_name).to eq("Roger")
      expect(person.last_name).to eq("Federer")
      expect(person.email).to eq("roger.federer@tennis.ch")
    end

    it "creates a person with reference only" do
      person = described_class.parse_from_request_header("HTTP_NIBR521" => "FEDERRO1")
      expect(person).not_to be(nil)
      expect(person.id).to eq(nil)
      expect(person.reference).to eq("federro1")
      expect(person.first_name).to eq(nil)
      expect(person.last_name).to eq(nil)
      expect(person.email).to eq(nil)
    end

    it "creates a person" do
      person = described_class.parse_from_request_header("HTTP_NIBR521" => "FEDERRO1", "HTTP_NIBRFIRST" => "Roger", "HTTP_NIBRLAST" => "Federer", "HTTP_NIBREMAIL" => "roger.federer@tennis.ch")
      expect(person).not_to be(nil)
      expect(person.id).to eq(nil)
      expect(person.reference).to eq("federro1")
      expect(person.first_name).to eq("Roger")
      expect(person.last_name).to eq("Federer")
      expect(person.email).to eq("roger.federer@tennis.ch")
      expect(person.full_name).to eq("Federer Roger")
    end

    it "creates a person with empty first and last name" do
      person = described_class.parse_from_request_header("HTTP_NIBR521" => "FEDERRO1", "HTTP_NIBRFIRST" => " ", "HTTP_NIBRLAST" => "", "HTTP_NIBREMAIL" => "  ")
      expect(person).not_to be(nil)
      expect(person.id).to eq(nil)
      expect(person.reference).to eq("federro1")
      expect(person.first_name).to eq(nil)
      expect(person.last_name).to eq(nil)
      expect(person.email).to eq(nil)
      expect(person.full_name).to eq(nil)
    end

    it "handles exceptions gracefully" do
      # Mock a scenario that would cause an exception
      allow_any_instance_of(String).to receive(:downcase).and_raise(StandardError, "Test error")
      person = described_class.parse_from_request_header("HTTP_NIBR521" => "TEST")
      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("Test error")
    end
  end

  context "payload" do
    before(:context) do
      Ehsso.configure do |config|
        # Application reference
        config.module_key = "my_module_key"

        # Service Endpoint
        config.base_url = "http://{host}:{port}"
      end
    end

    it "creates payload" do
      person = described_class.new(id: 0, reference: "123", first_name: "first_name", last_name: "last_name", email: "first_name.last_name@company.tld")
      # call a private method to test
      payload = person.send(:payload)

      expect(payload.class).to eq(Hash)
      expect(payload[:type]).to eq("request")
      expect(payload[:action]).to eq("people.modules.roles")
      expect(payload[:request][0][:reference]).to eq("123")
      expect(payload[:request][0][:first_name]).to eq("first_name")
      expect(payload[:request][0][:last_name]).to eq("last_name")
      expect(payload[:request][0][:email]).to eq("first_name.last_name@company.tld")
      expect(payload[:request][0][:modules][0][:reference]).to eq("my_module_key")
    end
  end

  context "service call" do
    before(:context) do
      Ehsso.configure do |config|
        # Application reference
        config.module_key = "my_module_key"

        # Service Endpoint
        config.base_url = "http://localhost:9999"
        config.username_and_password = "hello:world"
      end
    end

    it "fails with fetch to invalid endpoint" do
      person = described_class.new(reference: "federro1")
      person.fetch
      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("http://localhost:9999/people: [0] Couldn't connect to server")
    end

    it "fails with fetch_or_create to invalid endpoint" do
      person = described_class.new(reference: "federro1")
      person.fetch_or_create
      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("http://localhost:9999/people: [0] Couldn't connect to server")
    end

    it "handles a valid service call" do
      person = described_class.new(reference: "federro1")
      person.send(:handle_service_call, {action: "people.modules.roles", service_class: ServiceOk})

      expect(person.valid?).to eq(true)
      expect(person.first_name).to eq("Roger")
      expect(person.last_name).to eq("Federer")
      expect(person.email).to eq("roger.federer@tennis.ch")
      expect(person.guest?).to eq(true)
      expect(person.user?).to eq(true)
      expect(person.operator?).to eq(true)
      expect(person.administrator?).to eq(true)
    end

    it "handles fetch_or_create with valid service" do
      person = described_class.new(reference: "federro1")
      person.send(:handle_service_call, {action: "people_with_guest_registration_if_missing.modules.roles", service_class: ServiceOk})

      expect(person.valid?).to eq(true)
      expect(person.first_name).to eq("Roger")
      expect(person.last_name).to eq("Federer")
    end

    it "fails with not found person reference" do
      person = described_class.new(reference: "federro1")
      person.send(:handle_service_call, {action: "people.modules.roles", service_class: ServiceNotFound})

      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("person not found")
    end

    it "fails with 200 code but invalid json" do
      person = described_class.new(reference: "federro1")
      person.send(:handle_service_call, {action: "people.modules.roles", service_class: ServiceOkJsonIssue})

      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("Unable to parse service response data")
    end

    it "fails with error code and invalid json" do
      person = described_class.new(reference: "federro1")
      person.send(:handle_service_call, {action: "people.modules.roles", service_class: Service500JsonIssue})

      expect(person.valid?).to eq(false)
      expect(person.last_error_message).to eq("https://localhost:9999/people: [500] just a simple message")
    end
  end

  context "roles" do
    it "validates roles" do
      person = described_class.new(roles: ["GUEST", "USER"])
      expect(person.guest?).to eq(true)
      expect(person.user?).to eq(true)
      expect(person.operator?).to eq(false)
    end

    it "fails with invalid method" do
      person = described_class.new(roles: ["GUEST", "USER"])
      expect {
        person.unknown
      }.to raise_error(RuntimeError, "Method [unknown] not defined or allowed")
    end
  end

  context "dump/load" do
    it "can dump and load a Ehsso::Person object" do
      person = described_class.new(id: 0, reference: "123", first_name: "first_name", last_name: "last_name", email: "first_name.last_name@company.tld")
      person_in_yaml = YAML.dump(person)
      person2 = YAML.safe_load(person_in_yaml, permitted_classes: [Ehsso::Person])
      expect(person2).to have_attributes(id: 0, reference: "123", first_name: "first_name", last_name: "last_name", email: "first_name.last_name@company.tld")
    end
  end

  describe '#full_name' do
    subject(:full_name) { person.full_name }

    context 'when first_name and last_name present' do
      let(:person) {described_class.new(first_name: ' Roger ', last_name: ' Federer ')}
      it {is_expected.to eq('Federer Roger')}
    end

    context 'when first_name presents' do
      let(:person) {described_class.new(first_name: ' Roger ', last_name: nil )}
      it {is_expected.to eq('Roger')}
    end

    context 'when first_name contains only whitespaces' do
      let(:person) {described_class.new(first_name: '  ', last_name: 'Federer' )}
      it {is_expected.to eq('Federer')}
    end

    context 'when empty' do
      let(:person) {described_class.new(first_name: nil, last_name: nil )}
      it {is_expected.to be_nil}
    end

    context 'when empty strings' do
      let(:person) {described_class.new(first_name: '', last_name: '' )}
      it {is_expected.to be_nil}
    end
  end
end
