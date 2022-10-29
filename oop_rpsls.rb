module Clearable
  def clear_screen
    system('clear')
  end
end

ROCK = "\u{1FAA8}"     ## emojis
PAPER = "\u{1F4C4}"
SCISSORS = "\u{2702}"
LIZARD = "\u{1F98E}"
SPOCK = "\u{1F596}"

module Choosable
  SHORTHAND_MOVES = { 'r' => "rock",
                      'p' => "paper",
                      's' => "scissors",
                      'l' => "lizard",
                      'sp' => "spock" }

  def choice_translate(choice)
    SHORTHAND_MOVES.keys.include?(choice) ? SHORTHAND_MOVES[choice] : choice
  end
end

class Move
  VALUES = %w(rock paper scissors lizard spock)

  def >(other_move)
    winning_combo.include?(other_move.name)
  end

  def to_s
    name
  end
end

class Scissors < Move
  attr_reader :name, :winning_combo

  def initialize
    @name = "scissors"
    @winning_combo = ['lizard', 'paper']
  end
end

class Rock < Move
  attr_reader :name, :winning_combo

  def initialize
    @name = "rock"
    @winning_combo = ['lizard', 'scissors']
  end
end

class Paper < Move
  attr_reader :name, :winning_combo

  def initialize
    @name = "paper"
    @winning_combo = ['rock', 'spock']
  end
end

class Lizard < Move
  attr_reader :name, :winning_combo

  def initialize
    @name = "lizard"
    @winning_combo = ['spock', 'paper']
  end
end

class Spock < Move
  attr_reader :name, :winning_combo

  def initialize
    @name = "spock"
    @winning_combo = ['rock', 'scissors']
  end
end

class Player
  include Choosable
  include Clearable

  attr_accessor :move, :name, :score, :moves, :round_score

  MOVE_CHOICES = [Rock.new, Paper.new, Scissors.new, Lizard.new, Spock.new]

  def initialize
    @score = 0
    set_name
    @moves = Hash.new(0)
    @round_score = 0
  end

  def increase_scores
    self.score += 1
    self.round_score += 1
  end

  def winning_score?
    self.score == 5
  end

  def clear_move_history
    self.score = 0
    self.moves = Hash.new(0)
    self.round_score = 0
  end

  def player_moves
    moves[move.to_s] += 1
  end

  def move_history
    puts "Moves so far for #{name}:"
    moves.each_pair do |move, move_total|
      puts "#{move} = #{move_total}"
    end
    nil
  end

  def get_move(choice)
    MOVE_CHOICES.select do |object|
      choice == object.name
    end[0]
  end

  def to_s
    name
  end
end

class Human < Player
  include Clearable

  def set_name
    clear_screen
    n = nil
    loop do
      puts "Hello there..."
      puts "What's your name?"
      n = gets.chomp.squeeze
      break unless n.empty? || n.match?(/[^a-z]/i)
      puts "Sorry, must enter a name..."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock/r  #{ROCK}, paper/p  #{PAPER}, scissors/s  #{SCISSORS}, lizard/l  #{LIZARD} or spock/sp  #{SPOCK}:"
      choice = gets.chomp
      choice = choice_translate(choice)
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = get_move(choice)
    player_moves
  end
end

class Computer < Player
  def set_name
    self.name = %w(R2D2 C3PO Wally BB4).sample
  end

  def choose
    self.move = get_move(Move::VALUES.sample)
    player_moves
    clear_screen
  end
end

class RPSGame
  include Clearable

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  private

  def display_welcome_message
    clear_screen
    center_text("Welcome to the Rock, Paper, Scissors, Lizard, Spock game!")
    center_text("(#{ROCK}  #{PAPER}  #{SCISSORS}  #{LIZARD}  #{SPOCK})\n")
    center_text("The first one to 5 points wins the game.")
    center_text("----------------------------------------")
    center_text("You earn a point each time you win a round.\n\n")
    center_text("Good luck #{human}!")
  end

  def center_text(text)
    puts text.center(74)
  end

  def display_goodbye_message
    clear_screen
    puts "Thanks for playing #{human}.\n\n"
    puts "Please come play again soon!\n\n"
    puts "And have a wonderful rest of your day!\n\n"
  end

  def display_choices
    puts "#{human} chose #{human.move}"
    puts "#{computer} chose #{computer.move}.\n\n"
  end

  def display_moves
    display_choices
    round_winner
    puts "Round score so far:"
    puts "#{human} = #{human.round_score}"
    puts "#{computer} = #{computer.round_score}\n\n"
    puts human.move_history
    puts computer.move_history
  end

  def round_winner
    if human.move > computer.move
      puts "#{human} won this round!"
      human.increase_scores
    elsif computer.move > human.move
      puts "#{computer} won this round!"
      computer.increase_scores
    else
      puts "It's a tie!"
    end
  end

  def final_score
    puts "Final score:"
    puts "#{human} #{human.score} and #{computer} #{computer.score}!\n\n"
    human.clear_move_history
    computer.clear_move_history
  end

  def display_winner
    clear_screen
    if human.winning_score?
      puts "Congrats #{human}, you won the game! \u{1F483} \u{1F57A} \n\n"
      puts "Quick happy celebratory dance...\u{1F929} \u{1F973} \u{1F60E} \n\n"
    elsif computer.winning_score?
      puts "Aww... #{computer} won the game! \u{1F63F} \u{1F63F} \u{1F63F} \n\n"
      puts "You did your best though... \u{1F62C} \n\n"
    end
    final_score
  end

  def player_choices
    human.choose
    computer.choose
  end

  def winner?
    human.winning_score? || computer.winning_score?
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (Please enter Y or N)"
      answer = gets.chomp
      break if %w(y n).include?(answer.downcase)
      puts "Sorry, must be Y or N..."
    end

    answer.downcase == 'y'
  end

  public

  def play
    display_welcome_message
    loop do
      until winner?
        player_choices
        display_moves
      end
      display_winner
      break if play_again? == false
    end
    display_goodbye_message
  end
end

RPSGame.new.play
