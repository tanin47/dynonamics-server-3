class TunerController < ApplicationController


  #
  # Each user is queued separatedly
  #
  def index
    users = User.all(:conditions=>{:status=>User::STATUS_ACTIVE})
    
    users.each { |user|
      Delayed::Job.enqueue DynoTuner.new(user.id)
    }
    
    render :text=> "OK"
  end
  

  

  
  
end
