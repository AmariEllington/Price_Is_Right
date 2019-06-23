class Game < ActiveRecord::Base
  belongs_to :user
  has_many :questions

  def questions
    Question.all.select{|question| question.game_id == id}
  end

  def get_question
    questions.each do |question|
      if(!question.guess)
        return question
      end
    end
    return nil
  end

  def destroy_questions
    questions.each do |question|
      question.destroy
    end
  end

  def destroy_recursive
    destroy_questions
    self.destroy
  end

  def initialize_game(category)
    items = Scraper.category(category)
    items.each do |item|
      Question.create(game_id: self.id, item: item[:name], price: item[:price])
    end
  end
end


