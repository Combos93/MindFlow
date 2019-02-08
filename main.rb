require 'roo'                          # https://github.com/roo-rb/roo
require 'roo-xls'                      # https://github.com/roo-rb/roo-xls
require_relative 'lib/methods'

if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

FILE_PATH = "#{__dir__}/data/EngRus.xlsx"
HEADER_ROW = 0

english_words = []
russian_words = []

# FILE_PATH = "#{__dir__}/data/EngRus.{extension}"
# if xlsx => Roo::Spreadsheet.open
# elsif ods =>
# end

# ods = Roo::OpenOffice.new(FILE_PATH, password: "")           # stash for OpenOffice Support
# a = ods.column(1)                                            #
# b = ods.column(2)                                            #
# a.delete_at(HEADER_ROW)                                      #
# b.delete_at(HEADER_ROW)                                      #
#
# sheet = Roo::Excel.new('/Users/gturner/downloads/table.xls') # stash for Excel-2003 Support

excel = Roo::Spreadsheet.open(FILE_PATH)
worksheets = excel.sheets

excel.each_with_pagename do |_name, sheet|

  english_words = sheet.column(1) # парсинг eng
  russian_words = sheet.column(2) # парсинг rus

  english_words.each { |english| english.downcase! } # Приводим к нижнему регистру и Eng,
  russian_words.each { |russian| russian.downcase! } # и Rus

  russian_words.delete_at(HEADER_ROW)
  english_words.delete_at(HEADER_ROW)
end

worksheets.each do |worksheet|
  num_rows = 0

  excel.sheet(worksheet).each_row_streaming do |row|
    row.map { |cell| cell.value }
    num_rows += 1

    if row == []
      break
    end
  end

  puts "Найдено слов: #{num_rows - 1}"
end

puts "Сколько слов повторяем?"
how_many_words = STDIN.gets.chomp.to_i

puts "Сколько вариантов ответа будет? =)"
how_many_answers = STDIN.gets.chomp.to_i - 1

score = 0

counter = 1
while counter <= how_many_words
  sample_eng_word = english_words.sample # выбрать случайное английское слово; одно!; написать игроку
  puts "Слово: #{sample_eng_word}"

  index_sample_eng_word = english_words.index(sample_eng_word) + 2 # номер индекса случайного английского слова

  sample_russian_set = russian_words.sample(how_many_answers) # случайный русский набор ответов: русский набор слов(выбранное количество ответов - 1)
  right_answer = russian_words[index_sample_eng_word - 2] # случайный русский набор ответов << добавим

  sample_russian_set << right_answer # сюда верное англ. слово; по индексу, конечно, = англискому индексу.

  sample_russian_set.each { |word| word.downcase! }
  sample_russian_set.shuffle!.uniq! # случайный русский набор ответов перемешаем и уберём дубликаты
  puts

  # Проверочный цикл на повтор слов в массиве ответов. Добавляем по 1 слову и проверяем.
  until sample_russian_set.size == (how_many_answers + 1)
    sample_russian_set << russian_words.sample

    sample_russian_set.uniq!
  end

  sample_russian_set.each.with_index(1) do |word, index|
    puts "#{index}: #{word}"
  end

  puts "Вариант ответа: (можно один вариант перевода)"
  our_answer = STDIN.gets.chomp.to_s
  puts

  while our_answer == ''
    puts 'Вы не ввели вариант ответа!!!'
    puts 'Пожалуйста, напишите Ваше вариант ответа: (можно один вариант перевода)'
    our_answer = STDIN.gets.chomp.to_s
    puts
  end

  any_right_answer = right_answer.split(", ")

  if any_right_answer.include?(our_answer) #||                               # Либо пишем ответ
     # our_answer == (sample_russian_set.index(right_answer) + 1).to_s       # Либо его индекс (Чит-возможность=) )
    puts "Правильный ответ! =)\n\n-----"
    score += 1
  else
    puts "Не правильный ответ! =/ Правильный ответ \"#{right_answer}\"\n\n-----"
  end

  # Слово, которое уже было - выкидываем. Не повторяемся! =)
  # ОДНАКО НАД ЭТИМ ПОДУМАТЬ, КАК НАД ОПЦИОНАЛЬНОМ ФУНКЦИЕЙ
  # НЕ РАБОТАЕТ!!! ЛОМАЕТ ВСЁ!!! TESTING...................................
  #  english_words.delete_at(english_words.index(sample_eng_word))

  counter += 1
end

if score == how_many_words
  puts "Все ваши ответы - верны."
else
  puts "У вас #{score} правильных ответов из #{how_many_words}"
end