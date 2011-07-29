class HerokuClient
  
  def self.submit(path,method,headers={},data=nil,user=HEROKU_PROVIDER_NAME,password=HEROKU_PASSWORD)
    require 'restclient'
    
    r = RestClient::Resource.new("https://api.heroku.com", user, password)[path]
    
    heroku_headers = {
          'X-Heroku-API-Version' => '2',
          'User-Agent'           => "heroku-gem/1.17.16",
          'X-Ruby-Version'       => RUBY_VERSION,
          'X-Ruby-Platform'      => RUBY_PLATFORM
        }
        
    args     = [method, data, heroku_headers.merge(headers)].compact
    response = r.send(*args)

    return response
  end
  
  def self.get_info(app_name,username,api_key)
    require 'rexml/document'
    data = HerokuClient.submit("/apps/"+app_name,"get",{},nil,username,api_key)
    
    doc = REXML::Document.new(data)
    attrs = doc.elements.to_a('//app/*').inject({}) do |hash, element|
      hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash
    end
    
    return attrs
  end
end