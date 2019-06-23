# coding: utf-8
require_relative './config/environment'
require 'sinatra/activerecord/rake'
require 'tty-prompt'
require 'artii'
require 'colorize'
require 'pry'


def difficulties
  {
    "Hard" => 5,
    "Medium" => 10,
    "Easy" => 30
  }
end


def brk
  puts "
    "
end

def line
  puts Rainbow("-----------------------------------------------------------------------------------------------------------------").bright.blink
end

def title
  a = Artii::Base.new :font => 'slant'
  puts a.asciify('THE PRICE IS RIGHT!!!')
end

def header
  
  puts Rainbow("The aim of the game is to successfully guess the price of items💰💰💰💰....or to get as close as you can").underline.bright
  puts Rainbow("------------------------------------------------------").bright
  puts Rainbow("|| 1. You will select your difficulty                ||").bright
  puts Rainbow("|| Range each way - Easy: 30    Medium: 10   Hard: 5 ||").bright
  puts Rainbow("------------------------------------------------------").bright
  puts Rainbow("|| 2. You will select a category for your items.     ||").bright
  puts Rainbow("------------------------------------------------------").bright
  puts Rainbow("|| 3. You will try and guess the price of your items.||").bright
  puts Rainbow("------------------------------------------------------").bright
  puts Rainbow("|| 4. You will end up either a winner or loser.      ||").bright
  puts Rainbow("------------------------------------------------------").bright
  puts Rainbow("What is your name?").underline.bright
  name = gets.chomp
  a = Artii::Base.new :font => 'slant'
  puts a.asciify("#{name.upcase} COME ON DOWN!!!")  
end

def goodbye
  a = Artii::Base.new :font => 'slant'
  puts a.asciify('Goodbye')
end

def settings
  puts Rainbow("What is your name?").underline.bright
  name = gets.chomp
  user = User.get_user_by_name(name)
  if(!user)
    puts Rainbow("No account with that name!").underline.bright
    settings
  end
  
  menu = TTY::Prompt.new
  selection = menu.select("") do |a|
    a.choice 'Change name'
    a.choice 'Exit'
  end

  case selection
  when 'Change name'
    puts Rainbow("Enter your new name!").underline.bright
    new_name = gets.chomp
    user.change_name(new_name)
    puts Rainbow("Your new name is: #{new_name}!").underline.bright
  when 'exit'
    return
  end
end


def start_menu
  menu = TTY::Prompt.new
  selection = menu.select("") do |a|
    a.choice 'Play'
    a.choice 'Settings'
    a.choice 'Debug'
    a.choice 'Exit game'
  end

  case selection
  when 'Play'
    return
  when 'Settings'
    settings
  when 'Debug'
    binding.pry
    "   "
    start_menu
  when 'Exit game'
    a = Artii::Base.new :font => 'slant'  
    puts a.asciify('Goodbye!')
    exit
  end

end



def difficulty
  prompt = TTY::Prompt.new
  category = %w(Easy Medium Hard)
  prompt.select(Rainbow('Choose your difficulty?').underline.bright, category, filter: true)
end



def category
  prompt = TTY::Prompt.new
  category = %w(Electronics Home Baby Children Womens Mens Watches Games)
  prompt.select(Rainbow('Choose your category?').underline.bright, category, filter: true)
end

def loading
  spinner = TTY::Spinner.new("[:spinner] Loading Questions")
  100.times do
    spinner.spin
    sleep(0.1)
  end
  
  spinner.success('🍾🍾🍾🍾Successful🍾🍾🍾🍾')
end

def question_header
  a = Artii::Base.new :font => 'slant'
  puts a.asciify('QUESTIONS????')
end

def get_user(name)
  user = User.get_user_by_name(name)
  if !user
    user = User.create(name: name)
  else
    puts Rainbow("👋👋👋👋 Welcome back #{name} 👋👋👋").bright.underline
  end
  user
end

def diff(a,b)
  (a - b).abs
end

def rank
  a = Artii::Base.new :font => 'slant'
  puts a.asciify("HIGH SCORES")
  table_data = [
    { :name => User.scoreboard[0][:name], :score => User.scoreboard[0][:high_score]},
    { :name => User.scoreboard[1][:name], :score => User.scoreboard[1][:high_score]},
    { :name => User.scoreboard[2][:name], :score => User.scoreboard[2][:high_score]},
    { :name => User.scoreboard[3][:name], :score => User.scoreboard[3][:high_score]},
    { :name => User.scoreboard[4][:name], :score => User.scoreboard[4][:high_score]}
  ]
  Formatador.display_table(table_data)
end

def user_stats(user)
  a = Artii::Base.new :font => 'slant'
  puts a.asciify("YOUR STATS")
  Formatador.display_table(user.stats)
end


def run
  money_animation
  title
  start_menu
  name = header
  user = get_user(name)
  line
  brk
  game = Game.create(user_id: user.id, score: 0)
  line
  brk
  diff_range = difficulties[difficulty]
  cat = category
  loading
  game.initialize_game(cat)
  line
  brk
  question_header
  line
  brk
  question = game.get_question
  while question 
    puts Rainbow("- Guess the price of #{question.item}").bright.underline
    input = gets.chomp
    question.guess = input
    question.save
    if diff(input.to_i, question.price) < diff_range
      puts  "Correct, the price was #{question.price.to_i}👍 😁".colorize(:green)
      game.score += 1
      game.save
    else 
      puts "Incorrect, the price was #{question.price.to_i}👎 😭".colorize(:red)
    end
    question = game.get_question
  end
  a = Artii::Base.new :font => 'slant'
  puts a.asciify("You scored #{game.score} out of 10")
  rank
  user_stats(user)
  goodbye

end

run
