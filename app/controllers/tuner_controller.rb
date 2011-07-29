class TunerController < ApplicationController
  include TunerHelper
  
  def index
    
    conditions = ["status=?",Log::STATUS_PENDING]
    
    if params[:incoming_time]
      conditions = ["incoming_time=?",params[:incoming_time]]  
    end
    
    # query 
    logs = Log.all(:select =>"user_id,COUNT(1) AS num_requests, SUM(http_x_heroku_queue_wait_time) as sum_wait_time, MAX(id) as max_id, SUM(rails_end-rails_start) AS sum_service_time, MIN(http_x_request_start) AS start_time, MAX(rails_end) AS end_time",
               :conditions => conditions,
               :group => "user_id")
   
    str = ""
    
    checked_users = []
   
    # check users that have logs
    logs.each { |log|
      user = User.first(:conditions=>{:id=>log.user_id})
      checked_users.push(user.id)
      
      next if !user
      next if log.num_requests == 0
      
      if params[:test_mode] != "yes"
        Log.update_all(["status=?",Log::STATUS_CHECKED],["user_id=? AND status=? AND id <= ?",user.id,Log::STATUS_PENDING,log.max_id])
      end
      
      avg_wait_time = (log.sum_wait_time.to_f / log.num_requests.to_f)
      avg_service_time = (log.sum_service_time.to_f / log.num_requests.to_f)
      
      #next if is_acceptable(user.avg_waiting_time.to_f,avg_wait_time.to_f) # acceptable, no adjustment needed
      
      dyno = (HerokuClient.get_info(user.app_name,user.username,user.api_key)[:dynos].to_i rescue 0)

      new_dyno,new_wait_time =  calculate_dyno_by_MMn({:dyno=> dyno.to_f,
                                  :avg_service_time=>avg_service_time.to_f,
                                  :wanted_wait_time=>user.avg_waiting_time.to_f,
                                  :actual_wait_time=>avg_wait_time.to_f,
                                  :num_requests=>log.num_requests.to_f,
                                  :interval_time=>(log.end_time.to_f - log.start_time.to_f),
                                  :max_dyno=>user.max_dyno.to_f,
                                  :min_dyno=>1.to_f})
      
      # don't adjust to be less than 2
      new_dyno = user.min_dyno if new_dyno < user.min_dyno
      new_dyno = user.max_dyno if new_dyno > user.max_dyno
      new_dyno = dyno if user.status != User::STATUS_ACTIVE
      
      str += "user_id=#{user.id} from dyno=#{dyno} to dyno=#{new_dyno} (current_wait=#{avg_wait_time},new_wait_time=#{new_wait_time})\n"
      
      conditionally_submit_dyno(user,dyno,new_dyno)
        
      DynoHistory.create(:before_number=>dyno,
                          :after_number=>new_dyno,
                          :user_id=>user.id,
                          :before_avg_waiting_time=>avg_wait_time,
                          :before_avg_service_time=>avg_service_time,
                          :before_number_of_requests=>log.num_requests,
                          :before_wanted_time=>user.avg_waiting_time,
                          :created_time=>Time.now)
    }
    
    # check users that DO NOT have logs
    unchecked_users = User.all(:conditions=>["id NOT IN (?) AND `status`=?",checked_users,User::STATUS_ACTIVE])
    unchecked_users.each { |user|
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
      
    }
    
    render :text=>str
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
