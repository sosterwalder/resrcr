class JobsController < ApplicationController
  def index
    @jobs = Job.find(:all)
  end
  
  def new
    @job = Job.new
  end
  
  def create
    @job = Job.new(params[:job])
 
    respond_to do |format|
      if @job.save
        format.html  { redirect_to(:jobs,
                      :notice => 'Job was successfully created.') }
      else
        format.html  { render :action => "new" }
      end
    end
  end
end
