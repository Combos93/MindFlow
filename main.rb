if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require_relative 'lib/parser'
require_relative 'lib/input_info'
require_relative 'lib/conjecture'

FILE_PATH = "#{__dir__}/data/EngRus.xlsx"

# english_words = []
# russian_words = []

parser = Parser.new(FILE_PATH)
# puts parser.number_words
# puts parser.eng.inspect
english_words = parser.english
russian_words = parser.russian
# excel = Roo::Spreadsheet.open(FILE_PATH)
# worksheets = excel.sheets
#
# excel.each_with_pagename do |_name, sheet|
#
#   english_words = sheet.column(1) # парсинг eng
#   russian_words = sheet.column(2) # парсинг rus
#
#   english_words.each { |english| english.downcase! } # Приводим к нижнему регистру и Eng,
#   russian_words.each { |russian| russian.downcase! } # и Rus
#
#   russian_words.delete_at(HEADER_ROW)
#   english_words.delete_at(HEADER_ROW)
# end
#
# worksheets.each do |worksheet|
#   num_rows = 0
#
#   excel.sheet(worksheet).each_row_streaming do |row|
#     row.map { |cell| cell.value }
#     num_rows += 1
#
#     if row == []
#       break
#     end
#   end
# end

puts "#{parser.number_words}"

# russian = InputInfo.new(russian_words) # NEED THE FIIIXXXXXXXXXXXXXXXXXX!!!!!!!
# english = InputInfo.new(english_words)

puts "Сколько слов повторяем?"
how_many_words = STDIN.gets.chomp.to_i

puts "Сколько вариантов ответа будет? =)"
how_many_answers = STDIN.gets.chomp.to_i - 1

update_brain = Conjecture.new(english_words, russian_words,
                              how_many_words, how_many_answers)

until update_brain.finished?
  update_brain.sample_english_word # выбрать случайное английское слово; одно!;

  puts "Слово: #{update_brain.sample_eng_word}" # написать его игроку

  update_brain.index_sample_eng_word # номер индекса случайного английского слова

  update_brain.sample_russian_set # случайный русский набор ответов: русский набор слов(выбранное количество ответов
  # - 1)

  update_brain.right_answer # случайный русский набор ответов << добавим

  update_brain.add_right_answer

  update_brain.downcase
  update_brain.shuffle_uniq # случайный русский набор ответов перемешаем и уберём дубликаты

  puts

  # Проверочный цикл на повтор слов в массиве ответов. Добавляем по 1 слову и проверяем.
  until update_brain.check_uniq_set?
    update_brain.sample_russian_set << update_brain.sample_russian_word
    update_brain.sample_rus_uniq
  end

  update_brain.show_variants

  puts "Вариант ответа: (можно один вариант перевода)"
  our_answer = STDIN.gets.chomp.to_s
  puts

  while update_brain.empty_answer?(our_answer)
    puts 'Вы не ввели вариант ответа!!!'
    puts 'Пожалуйста, напишите Ваше вариант ответа: (можно один вариант перевода)'
    our_answer = STDIN.gets.chomp.to_s
    puts
  end

  update_brain.any_right_answer
  update_brain.turner_answers(our_answer)

  puts update_brain.answer
end

if update_brain.right == how_many_words
  puts "Все ваши ответы - верны."
else
  puts "У вас #{update_brain.right} правильных ответов из #{how_many_words}"
end
