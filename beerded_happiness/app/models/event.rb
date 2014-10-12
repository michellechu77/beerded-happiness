class Event < ActiveRecord::Base
  has_many :games, dependent: :destroy
  has_many :event_users
  has_many :users, through: :event_users
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  def current_game 
  	@current_game = self.games.find_by(status: "current")
  end

  def start_queue
  	unless current_game
  		self.games.second.update(status: "current")
  		self.games.second.users << first_player
  		self.games.first.destroy
  	end
  end

  def first_player
  	self.games.first.users.first
  end

  def two_games?
    if current_game == nil && self.games.where(status: "pending").count == 2
      start_queue
    end
  end

  def currently_playing
    self.current_game.users
  end

  def next_game(winner)
    @next_game = self.games.where(status: "pending").first
    if @next_game
      #@next_game.users.first.notify
      @next_game.users << winner
      @next_game.update(status: "current")
    else
      new_game = self.games.create(status:"pending")
      new_game.users << winner
    end


  end

end

#comment
