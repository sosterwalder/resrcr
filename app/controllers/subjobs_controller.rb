class SubjobsController < ApplicationController
  before_filter :load_common_resources
  
  def index
    @subjobs = Subjob.find(:all)
  end
  
  def new
    @subjob = Subjob.new    
  end
  
  def create
    params[:subjob][:resource_ids] ||= []
    @subjob = Subjob.new(params[:subjob])
 
    respond_to do |format|
      if @subjob.save
        format.html  { redirect_to(:subjobs,
                      :notice => 'Subjob was successfully created.') }
      else
        format.html  { render :action => "new" }
      end
    end
  end
  
  def show
    # Load subjob details
    @subjob = Subjob.find(params[:id])
  end
  
  private
  def load_common_resources
    # Get jobs
    @jobs = Job.find(:all, :order => :id)
    
    # Get resources
    @resources = Resource.find(:all, :order => :id)
  end
  
end
