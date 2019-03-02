if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require_relative 'lib/parser'
require_relative 'lib/conjecture'
require_relative 'lib/database'

print "Найдены вот такие файлы с данными. \nКакой Вы хотите открыть?\n\n"

data = Dir.glob("#{__dir__}/data/*").sort!
# data.push("Google Таблицы")

data.each.with_index(1) do |file_path, index|
  file_name = File.basename(file_path)
  puts "#{index}) #{file_name}"
end

choice = STDIN.gets.to_i - 1

if data[choice].include?("Google Таблицы")
  print "Пожалуйста, вставьте сюда url Вашей таблицы!\n\n"
  url = STDIN.gets.to_s
  parser = Parser.new(url)
elsif data[choice].include?('db')
  database = Database.new(data[choice])

  puts 'Какую таблицу желаете открыть?'
  database.result.each.with_index(1) do |table, index|
    table = table.join('')
    puts "#{index}) #{table}"
  end

  number_table = STDIN.gets.to_i - 1
  database.parsing(database.result[number_table])
else
  parser = Parser.new(data[choice])
end

if number_table == nil
  english_words = parser.english
  russian_words = parser.russian

  puts "#{parser.number_words}"
else
  english_words = database.eng_words
  russian_words = database.rus_words

  puts "#{database.count_rows}"
end


puts "Сколько слов повторяем?"
how_many_words = STDIN.gets.chomp.to_i

puts "Сколько вариантов ответа будет? =)"
how_many_answers = STDIN.gets.chomp.to_i - 1

update_brain = Conjecture.new(english_words, russian_words,
                              how_many_words, how_many_answers)

until update_brain.finished?
  # выбрать случайное английское слово; одно!
  update_brain.sample_english_word

  # и написать его игроку
  puts "Слово: #{update_brain.sample_eng_word}"

  # номер индекса случайного английского слова
  update_brain.index_sample_eng_word

  # случайный русский набор ответов: русский набор слов(выбранное количество ответов - 1)
  update_brain.sample_russian_set

  # случайный русский набор ответов << добавим
  update_brain.right_answer
  update_brain.add_right_answer
  update_brain.downcase

  # случайный русский набор ответов перемешаем и уберём дубликаты
  update_brain.shuffle_uniq

  puts

  # Проверочный цикл на повтор слов в массиве ответов. Добавляем по 1 слову и проверяем.
  until update_brain.check_uniq_set?
    update_brain.sample_russian_set << update_brain.sample_russian_word
    update_brain.sample_rus_uniq
  end

  update_brain.show_variants

  puts "Вариант ответа: (можно один вариант перевода)"
  our_answer = STDIN.gets.chomp.to_s.downcase
  puts

  while update_brain.empty_answer?(our_answer)
    puts 'Вы не ввели вариант ответа!!!'
    puts 'Пожалуйста, напишите Ваше вариант ответа: (можно один вариант перевода)'
    our_answer = STDIN.gets.chomp.to_s.downcase
    puts
  end

  update_brain.any_right_answer
  update_brain.turner_answers(our_answer)

  puts update_brain.answer
end

persent_of_right_answers = ((update_brain.right.to_f / how_many_words.to_i).to_f) * 100

if update_brain.right == how_many_words
  puts "Все ваши ответы - верны. \n\nСлов было загадано - #{how_many_words}."
elsif update_brain.right == 0
  puts "У вас #{update_brain.right}."
else
  puts "У вас #{Option.sklonenie(update_brain.right,
                          "правильный ответ",
                         "правильных ответа",
                        "правильных ответов")} из #{how_many_words}; " \

  "#{persent_of_right_answers.round(3)} % правильных ответов"
end
