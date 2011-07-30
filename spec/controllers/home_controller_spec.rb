require 'spec_helper'


describe HomeController do
  
  before (:each) do
  
    @user = User.create(:id=>1,
                  :dynonamics_key=>"aaaa",
                  :username=>"tanin47@gmail.com",
                  :api_key=>"",
                  :status=>User::STATUS_ACTIVE,
                  :app_name=>"app_name",
                  :created_date=>(Time.now-86400),
                  :max_dyno=>10,
                  :avg_waiting_time=>0.1,
                  :min_dyno=>3)
  end
  
  it "should pass authentication" do
    
    timestamp = Time.now.to_i
    get :index, {:id=>1,
                 :timestamp=>timestamp,
                 :token=>Digest::SHA1.hexdigest("1:#{HEROKU_SSO_SALT}:#{timestamp}").to_s,
                 "nav-data"=>"eyJhcHBuYW1lIjoiZHlub25hbWljcy1yYWlscy0zMDMiLCJhZGRvbnMiOlt7InNsdWciOiJhbWF6b25fcmRzIiwiaWNvbiI6Imh0dHBzOi8vYXBpLmhlcm9rdS5jb20vaW1hZ2VzL2FkZG9ucy9hZGRvbi1pY29uLWFtYXpvbl9yZHMtMjV4MjUucG5nIiwibmFtZSI6IkFtYXpvbiBSRFMifSx7InNsdWciOiJkeW5vbmFtaWNzOnRlc3QiLCJuYW1lIjoiRHlub25hbWljcyJ9LHsic2x1ZyI6ImR5bm9uYW1pY3Mtc3RhZ2luZzp0ZXN0IiwibmFtZSI6IkR5bm9uYW1pY3Mtc3RhZ2luZyJ9LHsic2x1ZyI6ImxvZ2dpbmc6YmFzaWMiLCJuYW1lIjoiTG9nZ2luZyJ9LHsic2x1ZyI6InNoYXJlZC1kYXRhYmFzZTo1bWIiLCJuYW1lIjoiU2hhcmVkIERhdGFiYXNlIn1dLCJhZGRvbiI6IkR5bm9uYW1pY3Mtc3RhZ2luZyBUZXN0In0"
                 } 
    
    response.should be_success
    
  end
  
  it "should pass authentication with session" do
    
    session[:user] = "1"
    session[:heroku_sso] = true
    get :index
    
    response.should be_success
    
  end
  
  it "should not pass authentication with session because user doesn't exist" do
    
    session[:user] = "2"
    session[:heroku_sso] = true
    get :index
    
    response.status.should == 403
    
  end

  it "should not pass authentication because the token is invalid" do
    
    timestamp = Time.now.to_i
    get :index, {:id=>1,
                 :timestamp=>timestamp,
                 :token=>Digest::SHA1.hexdigest("1:#{HEROKU_SSO_SALT}:#{timestamp}:AAAAA").to_s,
                 "nav-data"=>"eyJhcHBuYW1lIjoiZHlub25hbWljcy1yYWlscy0zMDMiLCJhZGRvbnMiOlt7InNsdWciOiJhbWF6b25fcmRzIiwiaWNvbiI6Imh0dHBzOi8vYXBpLmhlcm9rdS5jb20vaW1hZ2VzL2FkZG9ucy9hZGRvbi1pY29uLWFtYXpvbl9yZHMtMjV4MjUucG5nIiwibmFtZSI6IkFtYXpvbiBSRFMifSx7InNsdWciOiJkeW5vbmFtaWNzOnRlc3QiLCJuYW1lIjoiRHlub25hbWljcyJ9LHsic2x1ZyI6ImR5bm9uYW1pY3Mtc3RhZ2luZzp0ZXN0IiwibmFtZSI6IkR5bm9uYW1pY3Mtc3RhZ2luZyJ9LHsic2x1ZyI6ImxvZ2dpbmc6YmFzaWMiLCJuYW1lIjoiTG9nZ2luZyJ9LHsic2x1ZyI6InNoYXJlZC1kYXRhYmFzZTo1bWIiLCJuYW1lIjoiU2hhcmVkIERhdGFiYXNlIn1dLCJhZGRvbiI6IkR5bm9uYW1pY3Mtc3RhZ2luZyBUZXN0In0"
                 } 
    
    response.status.should == 403
    
  end
  
  it "should not pass authentication because the timestamp is outdated" do
    
    timestamp = Time.now.to_i - 6*60
    get :index, {:id=>1,
                 :timestamp=>timestamp,
                 :token=>Digest::SHA1.hexdigest("1:#{HEROKU_SSO_SALT}:#{timestamp}").to_s,
                 "nav-data"=>"eyJhcHBuYW1lIjoiZHlub25hbWljcy1yYWlscy0zMDMiLCJhZGRvbnMiOlt7InNsdWciOiJhbWF6b25fcmRzIiwiaWNvbiI6Imh0dHBzOi8vYXBpLmhlcm9rdS5jb20vaW1hZ2VzL2FkZG9ucy9hZGRvbi1pY29uLWFtYXpvbl9yZHMtMjV4MjUucG5nIiwibmFtZSI6IkFtYXpvbiBSRFMifSx7InNsdWciOiJkeW5vbmFtaWNzOnRlc3QiLCJuYW1lIjoiRHlub25hbWljcyJ9LHsic2x1ZyI6ImR5bm9uYW1pY3Mtc3RhZ2luZzp0ZXN0IiwibmFtZSI6IkR5bm9uYW1pY3Mtc3RhZ2luZyJ9LHsic2x1ZyI6ImxvZ2dpbmc6YmFzaWMiLCJuYW1lIjoiTG9nZ2luZyJ9LHsic2x1ZyI6InNoYXJlZC1kYXRhYmFzZTo1bWIiLCJuYW1lIjoiU2hhcmVkIERhdGFiYXNlIn1dLCJhZGRvbiI6IkR5bm9uYW1pY3Mtc3RhZ2luZyBUZXN0In0"
                 } 
    
    response.status.should == 403
    
  end
  
  it "should successfully save password and get api_key" do 
    
    session[:user] = "1"
    session[:heroku_sso] = true
    post :save_password, {:password=>"ninat"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_true
    
    User.first(:conditions=>{:id=>@user.id}).api_key.should == "81f3943dc7d4e638f8d359d2802c966e83fd9581"
    
  end

  it "should fail to save password because the password is wrong" do 
    
    session[:user] = "1"
    session[:heroku_sso] = true
    post :save_password, {:password=>"aaqw"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_false
    
  end
  
  it "should save min/max dyno" do
    session[:user] = "1"
    session[:heroku_sso] = true
    post :save_min_max_dyno, {:min_dyno=>1,:max_dyno=>2}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_true
    
    user = User.first(:conditions=>{:id=>@user.id})
    user.min_dyno.should == 1
    user.max_dyno.should == 2
  end
  
  it "should save avg_waiting_time" do
    session[:user] = "1"
    session[:heroku_sso] = true
    post :save_avg_waiting_time, {:avg_waiting_time=>100}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_true
    
    user = User.first(:conditions=>{:id=>@user.id})
    user.avg_waiting_time.should == 0.1
  end
end