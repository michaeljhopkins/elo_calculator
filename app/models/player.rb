class Player < ActiveRecord::Base
  has_many :won_games, foreign_key: 'winner_id', class_name: 'Game'
  has_many :lost_games, foreign_key: 'loser_id', class_name: 'Game'
  has_many :entries
  has_many :tournaments, through: :entries

  validates_presence_of :name, :rating
  validates_uniqueness_of :name

  scope :by_name, -> { order(:name) }

  def self.last_winner
    Game.last.winner
  end

  def self.last_loser
    Game.last.loser
  end

  def games
    Game.for_player(self.id).most_recent
  end

  def highest_rating_achieved
    won_games.pluck(:winner_rating).push(rating).max
  end

  def games_won_count
    won_games.count
  end

  def games_lost_count
    lost_games.count
  end

  def games_played_count
    games.count
  end

  def add_rating!(change_in_rating)
    update_attributes!(rating: rating + change_in_rating)
  end

  def subtract_rating!(change_in_rating)
    update_attributes!(rating: rating - change_in_rating)
  end
end
