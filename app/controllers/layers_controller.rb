class LayersController < ApplicationController
  respond_to :json
  
  def index
    respond_with Layer.all
  end

  def show
    respond_with Layer.find(params[:id])
  end
  
  def create
    respond_with Layer.create(params[:layer])
  end
  
  def update
    respond_with Layer.update(params[:id], params[:layer])
  end
  
  def destroy
    respond_with Layer.destroy(params[:id])
  end
end
