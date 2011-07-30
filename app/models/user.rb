class User < ActiveRecord::Base
  include GenerateKey
  
  before_create :generate_unique_key

  STATUS_ACTIVE = "ACTIVE"
  STATUS_INACTIVE = "INACTIVE"
  STATUS_DELETED = "DELETED"
  
  validates_numericality_of :max_dyno,:only_integer => true, :message => "please enter a number"
  validates_numericality_of :max_dyno,:greater_than => 0, :message => "please enter max dyno greater than 0"
  validates_numericality_of :avg_waiting_time, :message => "please enter a number"
  validates_numericality_of :avg_waiting_time,:greater_than => 0, :message => "please enter greater than 0"
  
  def obtain_user_data
    begin
      require 'json'

      response = JSON.parse(HerokuClient.submit('/vendor/apps/'+self.id.to_s,'get')) 
      
      self.app_name = response['name']
      self.username = response['owner_email']
      self.save
    rescue Exception => e
      if e.kind_of?(RestClient::Request::Unauthorized)
        self.api_key = ""
        self.save
      end
    end
  end

end