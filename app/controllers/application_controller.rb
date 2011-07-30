# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout "main"

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  protected
  def check_admin
    
    $is_admin = false
    
    if $user
      aesir = Aesir.first(:conditions=>{:username=>$user.username})
      
      $is_admin = true if aesir
    end
    
    if session[:impersonated_user] or params[:impersonated_user]
      
      session[:impersonated_user] = params[:impersonated_user] if params[:impersonated_user]
      
      $impersonated_user = User.first(:conditions=>{:id=>session[:impersonated_user]})
      
      if $impersonated_user
        $impersonated_user.obtain_user_data 
        $user = $impersonated_user
      end
    end
    
  end
  
  protected
  def authenticate_heroku_single_signon
    
    $user = nil
    
    if Rails.env == "development"
      $user = User.first(:conditions=>{:id=>1})
      session[:heroku_sso] = true
      #$user.obtain_user_data
      return
    end
  
    
    if params[:id] and params[:timestamp]
      pre_token = "#{params[:id]}:#{HEROKU_SSO_SALT}:#{params[:timestamp]}"
      token = Digest::SHA1.hexdigest(pre_token).to_s
      
      render :nothing=>true, :status => 403 and return if params[:token] != token
      render :nothing=>true, :status => 403 and return if params[:timestamp].to_i < (Time.now - 5*60).to_i
  
  
      $user = User.find(params[:id])
      render :nothing, :status => 404 and return if !$user
      
      session[:user] = $user.id
      session[:heroku_sso] = true
      cookies['heroku-nav-data'] = params['nav-data']
      
      $user.obtain_user_data
    elsif session[:heroku_sso] == true
      $user = User.first(:conditions=>{:id=>session[:user]})
      
      $user.obtain_user_data if $user
    end
    
    render :nothing=>true, :status => 403 if !$user
    
  end
end
