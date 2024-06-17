module ParseJsonSpecHelper
  def parse_json
    JSON.parse(response.body)
  end
end
