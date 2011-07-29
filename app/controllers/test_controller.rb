class TestController < ApplicationController
  
  def generate_test_data
    
    
    start_time = 0;
    (1..10).each { |i|
      
      (1..10).each { |a|
        Log.create( :incoming_time=>i, 
                    :user_id=>1,
                    :http_x_request_start=>start_time,
                    :rails_start=>start_time,
                    :rails_end=>start_time+i*i,
                    :http_x_heroku_queue_wait_time=>i*i,
                    :http_x_heroku_dyno_in_use=>0,
                    :http_x_heroku_queue_depth=>0,
                    :status=>Log::STATUS_PENDING
                    )
                    
        start_time = start_time + i*i
       
      }
    }
    
    render :text=>"OK"
  end
  
end
