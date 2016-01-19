class WatchlistsController < ApplicationController

  def index
    watchlists = Watchlist.all
    tags = {}
    watchlists.each do |w|
      tags[w.chat_id] = w.tags
    end

    render json: { status: 'ok', watchlists: watchlists.as_json, tags: tags.as_json }
  end

  def create
    chat_id = safe_params[:chat_id]
    tags = params[:tags]

    watchlist = Watchlist.find_by(chat_id: chat_id)
    watchlist = Watchlist.create(chat_id: chat_id) unless watchlist

    existing_tags = watchlist.tags
    existing_tags.destroy_all

    if (tags)
      tags.each do |t|
        watchlist.tags.build(tag: t)
        watchlist.save
      end
    end

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
    params.permit(:chat_id, tags: [])
  end
end
