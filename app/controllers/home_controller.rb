class HomeController < ApplicationController
#  protect_from_forgery
  before_filter :authenticate_heroku_single_signon, :check_admin
  
  def index
    
  end
  
  def save_password
    render :json=>{:ok=>false,:error_message=>"Please insert password"} and return if params[:password].strip == ""
    
    begin
      require 'json'
      response  = JSON.parse(HerokuClient.submit("/login","post",{:accept=>"json"},{ :username => $user.username, :password => params[:password] },$user.username,params[:password]))
      
      require 'pp'
      pp response
      
      $user.api_key = response['api_key']
      $user.save
      
      render :json=>{:ok=>true}
    rescue Exception=>e
      print "Error while logging in: #{e}\n\n"
      render :json=>{:ok=>false,:error_message=>"Cannot verify password with Heroku.com. Please try again later."}
    end
    
    
  end
  
  def save_min_max_dyno
    $user.max_dyno = params[:max_dyno]
    $user.min_dyno = params[:min_dyno]
    if !$user.save
      render :json=>{:ok=>false,:error_message=>$user.errors.full_messages}
    else
      render :json=>{:ok=>true}
    end
  end
  
  def save_avg_waiting_time
    $user.avg_waiting_time = params[:avg_waiting_time].to_f / 1000
    if !$user.save
      render :json=>{:ok=>false,:error_message=>$user.errors.full_messages}
    else
      render :json=>{:ok=>true}
    end
    
  end
  

  
  
  
end
