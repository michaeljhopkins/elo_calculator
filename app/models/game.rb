require 'csv'

class Game < ApplicationRecord
  belongs_to :winner, class_name: 'Player'
  belongs_to :loser, class_name: 'Player'
  belongs_to :matchup

  validates_presence_of :winner_id, :loser_id, :winner_rating, :loser_rating

  scope :most_recent, -> { order(id: :desc) }
  scope :prior_to, ->(date) { where('created_at < ?', date) }
  scope :chronologically, -> { order(id: :asc) }
  scope :played_on, ->(date) { where(created_at: (date.beginning_of_day.utc .. date.end_of_day.utc)).reverse_order }

  def self.to_csv
    attributes = %w(winner_rating loser_rating created_at updated_at winner_id loser_id)
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |game|
        csv << game.attributes.values_at(*attributes)
      end
    end
  end

  def can_undo?
    self == Game.last
  end

  def self.for_players(player1, player2)
    where("winner_id = #{player1.id} and loser_id = #{player2.id} or winner_id = #{player2.id} and loser_id = #{player1.id}").includes(:winner, :loser)
  end

  def self.for_player(player_id)
    where("winner_id = #{player_id} or loser_id = #{player_id}")
  end

  def next_game_for(player)
    Game.for_player(player.id).where('created_at > ?', created_at).first
  end

  def prior_to(day)
    Game.for_player(player.id).where('created_at > ?', created_at).first
  end

  def rating_for(player)
    winner_id == player.id ? winner_rating : loser_rating
  end

  def opponent_of(player)
    winner_id == player.id ? loser : winner
  end

end
