class WatchlistsController < ApplicationController

  def index
    watchlists = Watchlist.all

    render json: { status: 'ok', watchlists: watchlists.as_json }
  end

  def create
    chat_id = safe_params[:chat_id]
    watchlist = Watchlist.find_by(chat_id: chat_id)
    Watchlist.create(chat_id: chat_id) unless watchlist

    render json: { status: 'ok' }
  end

  def destroy
    chat_id = params[:id]
    watchlist = Watchlist.find_by(chat_id: chat_id)
    watchlist.destroy

    render json: { status: 'ok' }
  end

  private
  def safe_params
    params.require(:chat_id)
    params.permit(:chat_id, :tag)
  end
end
