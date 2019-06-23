class User < ActiveRecord::Base
  has_many :games

  def self.get_user_by_name(name)
    all.find{|user| user.name == name}
  end

  def new_game
    Game.new(user_id: id)
  end

  def games
    Game.all.select{|game| game.user_id == id}
  end

  def cull_games
    #culls games with a nil score or has no questions
    games.each do |game|
      if(!game.score || game.questions.length == 0)
        game.destroy_recursive
      end
    end
  end

  def accuracy
    cull_games
    (games.sum{|game| game.score.to_f / game.questions.length.to_f} / games.length.to_f) * 100
  end

  def best_game
     games.max_by{|game| game.score}
  end
  
  def high_score
    best_game.score
  end

  def stats
    [{
      :games_played => games.length,
      :high_score => high_score,
      :accuracy => "#{accuracy.to_i}%"
    }]
  end

  def change_name(new_name)
    self.update(name: new_name)
  end

  def self.top_five_users
    all.sort{|a, b| b.high_score <=> a.high_score}[0..4]
  end

  def self.scoreboard
    top_five_users.map do |user|
      {
        :name => user.name,
        :high_score => user.high_score
      }
    end
  end
  
  def self.clear_user_data(user)
    user.games.each do |game|
      game.destroy_recursive
    end
  end

  def self.destroy_user(user)
    clear_user_data(user)
    user.destroy
  end

  def self.destroy_all_users
    all.each do |user|
      destroy_user(user)
    end
  end
end
    
