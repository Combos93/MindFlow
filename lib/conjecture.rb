class Conjecture
  attr_reader :sample_eng_word, :sample_russian_set, :answer, :right

  def initialize(english, russian, how_many_words, how_many_answers)
    @english = english
    @russian = russian
    @how_many_words = how_many_words
    @how_many_answers = how_many_answers

    @right = 0 # Временно тут...
    @current_question = 0
  end

  def sample_english_word
    @sample_eng_word = @english.sample
  end

  def sample_russian_word
    @russian.sample
  end

  def index_sample_eng_word
    @index_sample_eng_word = @english.index(@sample_eng_word) + 2
  end

  def sample_russian_set
    @sample_russian_set = @russian.sample(@how_many_answers)
  end

  def add_right_answer
    @sample_russian_set << @right_answer
  end

  def right_answer
    @right_answer = @russian[@index_sample_eng_word - 2]
  end

  def finished?
    @current_question >= @how_many_words
  end

  def downcase
    @sample_russian_set.each {|word| word.downcase!}
  end

  def shuffle_uniq
    @sample_russian_set.shuffle!.uniq!
  end

  def sample_rus_uniq
    @sample_russian_set.uniq!
  end

  def check_uniq_set?
    @sample_russian_set.size == (@how_many_answers + 1)
  end

  def show_variants
    @sample_russian_set.each.with_index(1) do |word, index|
      puts "#{index}: #{word}"
    end
  end

  def empty_answer?(our_answer)
    our_answer == ''
  end

  def any_right_answer
    @any_right_answer = @right_answer.split(", ")
  end

  def turner_answers(our_answer)
    if check_answer?(our_answer)
      @answer = "\nПравильный ответ! =)\n\n-----"
    else
      @answer = "Не правильный ответ! =/ Правильный ответ \"#{@right_answer}\"\n\n-----"
    end

    @current_question += 1
  end

  def check_answer?(our_answer)
    @right += 1 if @any_right_answer.include?(our_answer) #|| # Либо пишем ответ
    # our_answer == (sample_russian_set.index(right_answer) + 1).to_s # Либо его индекс (Чит-возможность=) )
  end
end
