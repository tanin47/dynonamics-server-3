class HerokuController < ApplicationController

  before_filter :authenticate_heroku

  def create
    
    logger.debug { "params_from_heroku=#{params.inspect}" }
    
    user = User.create(:status=>User::STATUS_ACTIVE,
                        :plan=>params[:plan],
                        :callback_url=>params[:callback_url],
                        :app_name=>"",
                        :api_key=>"",
                        :username=>"",
                        :heroku_id=>params[:heroku_id],
                        :created_date=>Time.now,
                        :max_dyno=>5,
                        :min_dyno=>1,
                        :max_worker=>5,
                        :min_worker=>0,
                        :avg_waiting_time=>0.1)
                        
    if ENV['STAGING']
      key_url = "DYNONAMICS_STAGING_DYNO_URL"
    else
      key_url = "DYNONAMICS_DYNO_URL"
    end
    
    render :json => {:id=>user.id,
                    :config=>{key_url=>"http://"+DOMAIN_NAME+"/dynologger/"+user.dynonamics_key
                            }
                     } 
  end

  def destroy
    user = User.first(:conditions=>{:id=>params[:id]})
    
    user.status = "INACTIVE"
    user.save
    
    head :ok
  end

  protected
    def authenticate_heroku
      
      authenticate_or_request_with_http_basic do |user, password|
        user == HEROKU_PROVIDER_NAME && password == HEROKU_PASSWORD
      end
    end
end
