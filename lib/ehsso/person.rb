module Ehsso

  class Person

    attr_accessor :id
    attr_accessor :reference
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :email
    attr_accessor :module_key
    attr_accessor :module_name
    attr_accessor :roles

    attr_accessor   :last_error_message

    def initialize(args={})
      @id               = args[:id]
      @reference        = args[:reference]
      @first_name       = args[:first_name]
      @last_name        = args[:last_name]
      @email            = args[:email]

      # for this purpose we deal with only one module
      @module_key       = args[:module_key]
      @module_name      = args[:module_name]
      @roles            = args[:roles].is_a?(Array) ? args[:roles] : []
    end

    def valid?
      @last_error_message.nil?
    end

    # you can use methods like guest?, user?, operator?, administrator? etc.
    def method_missing(method)
      raise "Method [#{method}] not defined or allowed" unless method[-1] == '?'
      @roles.include?(method[0..-2].upcase)
    end

    def full_name
      return nil if self.last_name.nil? && self.first_name.nil?
      [self.last_name, self.first_name].compact.join(" ")
    end

    def self.parse_from_request_header(header={})
      person = Ehsso::Person.new()

      # reference (mandatory)
      if header['HTTP_NIBR521'].nil? || header['HTTP_NIBR521'].size == 0
        person.last_error_message = "Unable to extract HTTP_NIBR* porperties from request header"
        return person
      end

      person.reference = header['HTTP_NIBR521'].downcase

      [
        [:first_name=, 'HTTP_NIBRFIRST'],
        [:last_name=, 'HTTP_NIBRLAST'],
        [:email=, 'HTTP_NIBREMAIL']
      ].each do |method, key|
        person.send(method, header[key]) if header[key] && header[key].strip.size > 0
      end

      return person
    rescue => e
      person.last_error_message = e.to_s
      return person
    end

    def fetch
      handle_service_call(action: 'people.modules.roles')
    end

    def fetch_or_create
      handle_service_call(action: 'people_with_guest_registration_if_missing.modules.roles')
    end

    private

    def payload(args={})
      {
        type: 'request',
        action: args[:action] || 'people.modules.roles',
        request: [
          {
            reference: @reference,
            first_name: @first_name,
            last_name: @last_name,
            email: @email,
            modules: [
              {
                reference: args[:module_key] || Ehsso.configuration.module_key
              }
            ]
          }
        ]
      }
    end

    def handle_service_call(args={})
      url = [Ehsso.configuration.base_url, 'people'].join('/')
      userpwd = Ehsso.configuration.username_and_password

      # allows to mock class for rspec
      service_class = args[:service_class] || Typhoeus

      response = service_class.post(url, body: JSON.generate(payload(action: args[:action])), userpwd: userpwd, ssl_verifypeer: false)
      handle_response(response)
    end

    def handle_response(response)
      if response.code == 200
        begin
          data = JSON.parse(response.body)

          item = data['response'][0]
          @id = item['id']
          @reference = item['reference']
          @first_name = item['first_name']
          @last_name = item['last_name']
          @email = item['email']

          modul = item['modules'][0]
          @module_key = modul['reference']
          @module_name = modul['name']
          @roles = modul['roles']
          @last_error_message = nil
        rescue
          @last_error_message = "Unable to parse service response data"
        end
      else
        # something went wrong
        begin
          # try to parse the body to get valid error message
          data = JSON.parse(response.body)
          @last_error_message = data['response_message']
        rescue
          @last_error_message = "#{response.request.url}: [#{response.code}] #{response.return_message}"
        end
      end
    end

  end

end
