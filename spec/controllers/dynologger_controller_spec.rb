require 'spec_helper'


describe DynologgerController do

  before (:each) do
    
    @user = User.create(:id=>1,
                  :dynonamics_key=>"aaaa",
                  :username=>"test_username",
                  :api_key=>"the_api_key",
                  :status=>User::STATUS_ACTIVE,
                  :app_name=>"app_name",
                  :created_date=>(Time.now-86400),
                  :max_dyno=>10,
                  :avg_waiting_time=>0.1,
                  :min_dyno=>3)
  end
  
  it "logs" do
    
    post :index, {:dynonamics_key => "aaaa",
                  :http_x_request_start => 1,
                  :rails_start => 2,
                  :rails_end => 3,
                  :http_x_heroku_queue_wait_time => 4,
                  :http_x_heroku_dyno_in_use => 5,
                  :http_x_heroku_queue_depth => 6}
                  
    response.should be_success
    
    response.body.should == "OK"
    
    last_log = Log.first(:order=>"created_date DESC")
    
    last_log.user_id.should == @user.id
    last_log.status.should == Log::STATUS_PENDING
    last_log.http_x_request_start.should == 1.0
    last_log.rails_start.should == 2.0
    last_log.rails_end.should == 3.0
    last_log.http_x_heroku_queue_wait_time.should == 4.0
    last_log.http_x_heroku_dyno_in_use.should == 5.0
    last_log.http_x_heroku_queue_depth.should == 6.0
    
  end
  
  it "does not log because user is invalid" do
    
    post :index, {:dynonamics_key => "bbbb",
                  :http_x_request_start => 1,
                  :rails_start => 2,
                  :rails_end => 3,
                  :http_x_heroku_queue_wait_time => 4,
                  :http_x_heroku_dyno_in_use => 5,
                  :http_x_heroku_queue_depth => 6}
                  
    response.should be_success
    
    response.body.should == "Key is invalid."
  end
  
  it "does not log because user is invalid" do
    
    @user.status = User::STATUS_INACTIVE
    @user.save
    
    post :index, {:dynonamics_key => "aaaa",
                  :http_x_request_start => 1,
                  :rails_start => 2,
                  :rails_end => 3,
                  :http_x_heroku_queue_wait_time => 4,
                  :http_x_heroku_dyno_in_use => 5,
                  :http_x_heroku_queue_depth => 6}
                  
    response.should be_success
    
    response.body.should == "User is not active."
  end

  
end