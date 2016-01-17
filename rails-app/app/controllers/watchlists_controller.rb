class WatchlistsController < ApplicationController

  def create
    chat_id = safe_params[:chat_id]
    watchlist = Watchlist.find_by(chat_id: chat_id)
    Watchlist.create(chat_id: chat_id, last_notified: Time.now) unless watchlist

    render json: { status: 'ok' }
  end

  def destroy
    chat_id = params[:id]
    watchlist = Watchlist.find_by(chat_id: chat_id)
    watchlist.destroy

    render json: { status: 'ok' }
  end

  def notify
    watchlists = Watchlist.all
    notified_gundams = NotifiedGundam.last(50)
    notified_gundams_ids = notified_gundams.map(&:carousell_id)

    gundams = Gundam.last(5).reverse
    gundams = gundams.map do |g|
      g unless notified_gundams_ids.include?(g.carousell_id)
    end
    gundams.compact!

    notified = []
    notified = watchlists.map do |w|
      { w.chat_id => gundams.as_json }
    end if watchlists

    notified_gundams = gundams.map do |g|
      { carousell_id: g.carousell_id }
    end if gundams
    NotifiedGundam.create(notified_gundams)

    render json: { status: 'ok', notified: notified }
  end

  private
  def safe_params
    params.require(:chat_id)
    params.permit(:chat_id, :tag)
  end
end
