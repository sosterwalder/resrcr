class SystemController < ApplicationController
  def index
    @system = System.find_or_create_by_id(1)
  end
  
  def update
    logger.debug YAML::dump(params)
    
    @system = System.find(params[:id])
    
    respond_to do |format|
      if @system.update_attributes(params[:system])
        format.html  { redirect_to({:action => :index},
                      :notice => 'Settings were successfully updated.') }
      else
        format.html  { render :action => "index" }
      end
    end
  end
  
end