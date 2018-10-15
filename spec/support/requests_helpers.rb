module RequestsHelpers
  module JsonHelpers
    def json
      JSON.parse(response_body)
    end
  end
end
