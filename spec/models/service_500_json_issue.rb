class FakeRequest

  def url
    'https://localhost:9999/people'
  end

end

class Response500JsonIssue

  def code
    500
  end

  def body
    'just a simple message'
  end

  def return_message
    body
  end

  def request
    FakeRequest.new
  end

end

class Service500JsonIssue
  def self.post(url, args={})
    Response500JsonIssue.new
  end
end
