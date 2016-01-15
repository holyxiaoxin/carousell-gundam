class GundamsController < ApplicationController

  def create
    # Get array of new gundams to insert into db
    carousell_ids = safe_params.map do |g|
      g[:carousell_id]
    end
    existing_gundams_ids = Gundam.where(carousell_id: carousell_ids).map(&:carousell_id)
    new_gundams = safe_params.map do |g|
      g unless existing_gundams_ids.include?(g[:carousell_id].to_i)
    end
    new_gundams.compact!
    #

    gundam = Gundam.create(new_gundams)

    if gundam
      render json: { status: 'ok' }
    else
      render json: { status: 'fail' }
    end
  end

  def recent
    gundams = Gundam.all

    render json: gundams
  end

  private
  def safe_params
    params.require(:gundams).map { |g| g.permit(:title, :carousell_id, :description, :location_address, :location_name) }
  end
end
