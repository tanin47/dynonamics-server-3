require 'spec_helper'

class Tuner
  private
    def conditionally_submit_dyno(user,dyno,new_dyno)

    end
end

describe TunerController do

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
  
  it "adjust up" do
    
    DynoHistory.create(:before_number=>0,
                        :after_number=>5,
                        :created_time=>(Time.now-60*30),
                        :user_id=>@user.id)
    
    100.times { |i|
      Log.create(:user_id=>@user.id,
                :incoming_time=>i,
                :http_x_request_start=>i,
                :rails_start=>i,
                :rails_end=>i+1,
                :http_x_heroku_queue_wait_time=>1,
                :http_x_heroku_queue_depth=>0,
                :status=>Log::STATUS_PENDING,
                :created_date=>Time.now)
    }
    
    get :index
    
    Delayed::Worker.new.work_off
    
    d = DynoHistory.first(:conditions=>{:user_id=>@user.id},:order=>"created_time DESC")
    
    d.after_number.should == 7
    
    user = User.first(:conditions=>@user.id)
    
    user.last_adjustment_time.should_not == nil
    user.last_adjustment_time.to_i.should > (Time.now.to_i-30)
      
  end
  
  it "adjust down" do
    
    DynoHistory.create(:before_number=>0,
                        :after_number=>5,
                        :created_time=>(Time.now-60*30),
                        :user_id=>@user.id)
    
    100.times { |i|
      Log.create(:user_id=>@user.id,
                :incoming_time=>i,
                :http_x_request_start=>i,
                :rails_start=>i,
                :rails_end=>i+1,
                :http_x_heroku_queue_wait_time=>0.05,
                :http_x_heroku_queue_depth=>0,
                :status=>Log::STATUS_PENDING,
                :created_date=>Time.now)
    }
    
    get :index
    
    Delayed::Worker.new.work_off
    
    d = DynoHistory.first(:conditions=>{:user_id=>@user.id},:order=>"created_time DESC")
    
    d.after_number.should == 4
    
    user = User.first(:conditions=>@user.id)
    
    user.last_adjustment_time.should_not == nil
    user.last_adjustment_time.to_i.should > (Time.now.to_i-30)
      
  end
  
  it "has no log, it should set to min_dyno" do
    get :index
    
    Delayed::Worker.new.work_off
    
    d = DynoHistory.first(:conditions=>{:user_id=>@user.id},:order=>"created_time DESC")
    
    d.before_number.should eql(0)
    d.after_number.should eql(@user.min_dyno)
    d.before_avg_waiting_time.should eql(0)
    d.before_avg_service_time.should eql(0)
    d.before_number_of_requests.should eql(0)
    d.before_wanted_time.should eql(0)


    user = User.first(:conditions=>@user.id)
    
    user.last_adjustment_time.should_not == nil
    user.last_adjustment_time.to_i.should > (Time.now.to_i-30)
  end
  
  it "user does not exist, therefore, there is not tuning" do
    
    get :index
    
    @user.destroy
    
    Delayed::Worker.new.work_off
    
    d = DynoHistory.count()
    
    d.should == 0
      
  end
  
  it "user is inactive, therefore, there is no tuning" do
    
    get :index
    
    @user.status = User::STATUS_INACTIVE
    @user.save
    
    Delayed::Worker.new.work_off
    
    d = DynoHistory.count()
    
    d.should == 0
      
  end
  
  it "just run, therefore, it should run again" do
    
    DynoHistory.create(:before_number=>0,
                        :after_number=>5,
                        :created_time=>(Time.now-60*30),
                        :user_id=>@user.id)
    
    100.times { |i|
      Log.create(:user_id=>@user.id,
                :incoming_time=>i,
                :http_x_request_start=>i,
                :rails_start=>i,
                :rails_end=>i+1,
                :http_x_heroku_queue_wait_time=>5000,
                :http_x_heroku_queue_depth=>0,
                :status=>Log::STATUS_PENDING,
                :created_date=>Time.now)
    }
    
    get :index
    
    Delayed::Worker.new.work_off
    
    user = User.first(:conditions=>@user.id)
    
    user.last_adjustment_time.should_not == nil
    user.last_adjustment_time.to_i.should > (Time.now.to_i-30)
    
    last_adjustment_time = user.last_adjustment_time
    
    100.times { |i|
      Log.create(:user_id=>@user.id,
                :incoming_time=>i,
                :http_x_request_start=>i,
                :rails_start=>i,
                :rails_end=>i+1,
                :http_x_heroku_queue_wait_time=>5000,
                :http_x_heroku_queue_depth=>0,
                :status=>Log::STATUS_PENDING,
                :created_date=>Time.now)
    }
    
    get :index
    Delayed::Worker.new.work_off
    
    d = DynoHistory.count()
    
    d.should == 2
    
    user = User.first(:conditions=>@user.id)
    user.last_adjustment_time.to_i.should == last_adjustment_time.to_i
  end
end
