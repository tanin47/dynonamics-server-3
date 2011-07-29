class ReportController < ApplicationController
  
  before_filter :authenticate_heroku_single_signon, :check_admin
  
  def view_report
    view_date = Time.parse(params[:view_date])
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"home/report_graph",:locals=>{:date=>view_date.strftime('%Y-%m-%d')})}
  end
end
