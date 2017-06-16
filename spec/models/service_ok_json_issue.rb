class ResponseJsonIssue

  def code
    200
  end

  def body
    '{]' # just return invalid json
  end

end

class ServiceOkJsonIssue
  def self.post(url, args={})
    ResponseJsonIssue.new
  end
end
