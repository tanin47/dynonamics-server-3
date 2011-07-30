class DynologgerController < ApplicationController
  
  def index

    user = User.first(:conditions=>{:dynonamics_key=>params[:dynonamics_key]})

    if !user
      Rails.logger.info { "user is nil" }
      render :text=>"Key is invalid."
      return 
    end
    
    if user.status != User::STATUS_ACTIVE
      Rails.logger.info { "user is not active" }
      render :text=>"User is not active."
      return 
      
    end

    log = Log.new( :user_id=>user.id,
                :http_x_request_start=>params[:http_x_request_start],
                :rails_start=>params[:rails_start],
                :rails_end=>params[:rails_end],
                :http_x_heroku_queue_wait_time=>params[:http_x_heroku_queue_wait_time],
                :http_x_heroku_dyno_in_use=>params[:http_x_heroku_dyno_in_use],
                :http_x_heroku_queue_depth=>params[:http_x_heroku_queue_depth],
                :incoming_time=>Time.now.to_f,
                :created_date=>Time.now,
                :status=>Log::STATUS_PENDING
                )
    
    if !log.save
      Rails.logger.info { "Cannot save log error_message=#{log.errors.full_messages}" } 
    end
                
    render :text=>"OK"

  end
end
