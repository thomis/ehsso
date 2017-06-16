class ResponseNotFound

  def code
    404
  end

  def body
    '{
      "type": "response",
      "action": "people.modules.roles",
      "response_code": 404,
      "response_message": "person not found",
      "response_error_count": 1,
      "response": [
        {
          "id": null,
          "reference": "federro1",
          "first_name": null,
          "last_name": null,
          "email": null,
          "response_code": 404,
          "modules": [
            {
              "reference": "cm_chbs_portal",
              "name": null,
              "response_code": 0,
              "roles": []
            }
          ]
        }
      ]
    }'
  end

end

class ServiceNotFound
  def self.post(url, args={})
    ResponseNotFound.new
  end
end
