class TunerController < ApplicationController


  #
  # Each user is queued separatedly
  #
  def index
    users = User.all(:conditions=>{:status=>User::STATUS_ACTIVE})
    
    users.each { |user|
      Tuner.new(user.id).perform
    }
    
    render :text=> "OK"
  end
  

  

  
  
end
