class PlayerStatsController < ApplicationController
  before_action :player_must_exist

  def show
    render json: PlayerStatistician.new(player).ratings_over_time(params[:limit])
  end

  private

  def player_must_exist
    head :not_found unless player
  end

  def player
    @player || Player.find_by_id(params[:id])
  end
end
