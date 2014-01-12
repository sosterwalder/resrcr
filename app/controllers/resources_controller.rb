class ResourcesController < ApplicationController
  def index
    @resources = Resource.find(:all)
  end
  
  def new
    @resource = Resource.new
  end
  
  def create
    @resource = Resource.new(params[:resource])
 
    respond_to do |format|
      if @resource.save
        format.html  { redirect_to(:resources,
                      :notice => 'Resource was successfully created.') }
      else
        format.html  { render :action => "new" }
      end
    end
  end
end
