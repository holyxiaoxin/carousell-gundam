class AdminController < ApplicationController
  def watchlists_index
    if (!params[:key] || params[:key] != ENV['CAROUSELL_GUNDAM_ADMIN_PASSWORD'])
      return render json: { status: 'fail' }, status: :unauthorized
    end

    watchlists = Watchlist.all
    tags = {}
    watchlists.each do |w|
      tags[w.chat_id] = w.tags
    end

    render json: { status: 'ok', watchlists: watchlists.as_json, tags: tags.as_json }
  end
end
