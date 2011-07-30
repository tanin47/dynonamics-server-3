class DynoTuner
  include TunerHelper
  
  def initialize(user_id)
    @user_id = user_id
  end
  
  def perform
    
    begin
      
      user = User.first(:conditions=>{:id=>@user_id})
      
      return if !user or user.status != User::STATUS_ACTIVE
      
      return if user.last_adjustment_time and (Time.now.to_i - user.last_adjustment_time.to_i) < ADJUSTMENT_INTERVAL_SECONDS
      
      conditions = ["status=? AND user_id=?",Log::STATUS_PENDING,@user_id]
      
      # query 
      log = Log.first(:select =>"user_id,COUNT(1) AS num_requests, SUM(http_x_heroku_queue_wait_time) as sum_wait_time, MAX(id) as max_id, SUM(rails_end-rails_start) AS sum_service_time, MIN(http_x_request_start) AS start_time, MAX(rails_end) AS end_time",
                 :conditions => conditions,
                 :group=>"user_id")
     
      if log
        adjust_dyno(log,user)
        
        Log.update_all(["status=?",Log::STATUS_CHECKED],["user_id=? AND status=? AND id <= ?",user.id,Log::STATUS_PENDING,log.max_id])
        
      else
        adjust_nothing(user)
      end
      
      
      
      user.update_attributes(:last_adjustment_time=>Time.now)
      
    rescue Exception=>e
      
      TunerLog.create(:data=>"user_id=#{@user_id}",
                      :error_message=>"#{e.to_s}\n#{e.backtrace.join('\n')}",
                      :created_time=>Time.now.utc)
                      
    end
    
    Delayed::Job.enqueue(DynoTuner.new(@user_id),:run_at=> ADJUSTMENT_INTERVAL_SECONDS.minutes.from_now)
  end
    
  def adjust_dyno(log,user)
      
      avg_wait_time = (log.sum_wait_time.to_f / log.num_requests.to_f)
      avg_service_time = (log.sum_service_time.to_f / log.num_requests.to_f)
      
      last_dyno_history = DynoHistory.first(:conditions=>{:user_id=>user.id},:order=>"created_time DESC")
      
      dyno = (HerokuClient.get_info(user.app_name,user.username,user.api_key)[:dynos].to_i rescue (last_dyno_history.after_number rescue 0))

      new_dyno,new_wait_time =  calculate_dyno_by_MMn({:dyno=> dyno.to_f,
                                  :avg_service_time=>avg_service_time.to_f,
                                  :wanted_wait_time=>user.avg_waiting_time.to_f,
                                  :actual_wait_time=>avg_wait_time.to_f,
                                  :num_requests=>log.num_requests.to_f,
                                  :interval_time=>(log.end_time.to_f - log.start_time.to_f),
                                  :max_dyno=>user.max_dyno.to_f,
                                  :min_dyno=>1.to_f})
      
      # don't adjust to be less than user.min_dyno
      new_dyno = user.min_dyno if new_dyno < user.min_dyno
      new_dyno = user.max_dyno if new_dyno > user.max_dyno
      new_dyno = dyno if user.status != User::STATUS_ACTIVE
      
      conditionally_submit_dyno(user,dyno,new_dyno)
        
      DynoHistory.create(:before_number=>dyno,
                          :after_number=>new_dyno,
                          :user_id=>user.id,
                          :before_avg_waiting_time=>avg_wait_time,
                          :before_avg_service_time=>avg_service_time,
                          :before_number_of_requests=>log.num_requests,
                          :before_wanted_time=>user.avg_waiting_time,
                          :created_time=>Time.now)
  end
    
  def adjust_nothing(user)
    
    dyno = (HerokuClient.get_info(user.app_name,user.username,user.api_key)[:dynos].to_i rescue 0)
    new_dyno = user.min_dyno
    
    conditionally_submit_dyno(user,dyno,new_dyno)
    
    DynoHistory.create(:before_number=>dyno,
                  :after_number=>new_dyno,
                  :user_id=>user.id,
                  :before_avg_waiting_time=>0,
                  :before_avg_service_time=>0,
                  :before_number_of_requests=>0,
                  :before_wanted_time=>0,
                  :created_time=>Time.now)
                  
  end
  


  
  
  private
    def conditionally_submit_dyno(user,dyno,new_dyno)
      
      if dyno != new_dyno \
         and user.api_key != "" \
         and user.status == User::STATUS_ACTIVE
        
        begin
          HerokuClient.submit("/apps/#{user.app_name}/dynos","put",{},{:dynos=>new_dyno},user.username,user.api_key)
        rescue Exception=>e
          if e.kind_of?(RestClient::Request::Unauthorized)
            user.api_key = ""
            user.save
          end
        end
      end
      
    end
  
  private
    def is_acceptable(expected,actual)
      gap = expected.to_f * 0.20
      
      return (((expected - gap) < actual) && (actual < (expected + gap) ))
    end
  
end