class ResponseOk
  def code
    200
  end

  def body
    '{
      "type": "response",
      "action": "people.modules.roles",
      "response_code": 200,
      "response_error_count": 0,
      "response": [
        {
          "id": "100159",
          "reference": "federro1",
          "first_name": "Roger",
          "last_name": "Federer",
          "email": "roger.federer@tennis.ch",
          "response_code": 200,
          "modules": [
            {
              "reference": "cm_chbs_portal",
              "name": "CM Portal Basel",
              "response_code": 200,
              "roles": [
                "USER",
                "OPERATOR",
                "ADMINISTRATOR",
                "GUEST"
              ]
            }
          ]
        }
      ]
    }'
  end
end

class ServiceOk
  def self.post(url, args = {})
    ResponseOk.new
  end
end
