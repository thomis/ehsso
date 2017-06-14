module Ehsso

  class Person

    attr_accessor :id
    attr_accessor :reference
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :email

    attr_reader   :last_error_message

    def initialize(args={})
      @id               = args[:id]
      @reference        = args[:reference]
      @first_name       = args[:first_name]
      @last_name        = args[:last_name]
      @email            = args[:email]

      # for this purpose we deal with only one module
      @module_key       = nil
      @module_name      = nil
      @roles            = []
    end

    # def method_missing(method)
    #   @roles.include?(method[0..-2].to_sym)
    # end

    def full_name
      return nil if self.last_name.nil? && self.first_name.nil?
      [self.last_name, self.first_name].compact.join(" ")
    end

    def self.parse_from_request_header(header={})
      return nil unless header.is_a?(Hash)

      person = Ehsso::Person.new()

      # reference (mandatory)
      return nil if header['HTTP_NIBR521'].nil? || header['HTTP_NIBR521'].size == 0
      person.reference = header['HTTP_NIBR521'].downcase

      # first name
      person.first_name = header['HTTP_NIBRFIRST'] if header['HTTP_NIBRFIRST'] && header['HTTP_NIBRFIRST'].strip.size > 0

      # last name
      person.last_name = header['HTTP_NIBRLAST'] if header["HTTP_NIBRLAST"] && header['HTTP_NIBRFIRST'].strip.size > 0

      # email
      person.email = header['HTTP_NIBREMAIL'].downcase if header['HTTP_NIBREMAIL'] && header['HTTP_NIBREMAIL'].strip.size > 0

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
            reference: self.reference,
            first_name: self.first_name,
            last_name: self.last_name,
            email: self.email,
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
      response = Typhoeus.post(url, body: payload(action: args[:action]), userpwd: userpwd)
      handle_response(response)
    end

    def handle_response(response)
      if response.code == 200
        begin
          data = JSON.parse(response.body)

          item = data['response'][0]
          self.id = item['id']
          self.reference = item['reference']
          self.first_name = item['first_name']
          self.last_name = item['last_name']
          self.email = item['email']

          modul = item['modules'][0]
          self.module_key = modul['reference']
          self.module_name = modul['name']
          self.roles = modul['roles']
          self.last_error_message = nil
        rescue
          self.last_error_message = "Unable to parse servcie response data"
        end
      else
        # something went wrong
        begin
          # try to parse the body to get valid error message
          data = JSON.parse(response.body)
          self.last_error_message = data['response_message']
        rescue
          self.last_error_message = "#{response.request.url}: [#{response.code}] #{response.return_message}"
        end
      end
    end

  end

end
