class DynologgerController < ApplicationController
  
  def index

    user = User.first(:conditions=>{:dynonamics_key=>params[:dynonamics_key]})

    logger.info { "user is not nil" } and \
    render :text=>"Key is invalid. (" + params[:dynonamics_key] + ")" and return if !user

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
                
    logger.info { "Cannot save log error_message=#{log.errors.full_messages}" } if !log.save
                
    render :text=>"OK"

  end
end
