require 'roo'
require_relative 'lib/methods'

if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

FILE_PATH = "#{__dir__}/data/EngRus.xlsx"
english_words = []
russian_words = []

excel = Roo::Spreadsheet.open(FILE_PATH)
worksheets = excel.sheets

excel.each_with_pagename do |_name, sheet|

  english_words = sheet.column(1) #Реализовал парсинг eng
  russian_words = sheet.column(2) #Реализовал парсинг rus

  russian_words.delete_at(0)
  english_words.delete_at(0)
end

worksheets.each do |worksheet|
  num_rows = 0

  excel.sheet(worksheet).each_row_streaming do |row|
    row.map { |cell| cell.value.downcase }
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

  puts "Вариант ответа: (пишем полностью)"
  our_answer = STDIN.gets.chomp.to_s
  puts

  while our_answer == ''
    puts 'Вы не ввели вариант ответа!!!'
    puts 'Пожалуйста, напишите Ваше вариант ответа: (пишем полностью)'
    our_answer = STDIN.gets.chomp.to_s
    puts
  end

  any_right_answer = right_answer.delete(",").split(/ /)

  if any_right_answer.include?(our_answer)
    puts "Правильный ответ! =)\n\n-----"
  else
    puts "Не правильный ответ! =/ Правильный ответ \"#{right_answer}\"\n\n-----"
  end

  # Слово, которое уже было - выкидываем. Не повторяемся! =)
  # ОДНАКО НАД ЭТИМ ПОДУМАТЬ, КАК НАД ОПЦИОНАЛЬНОМ ФУНКЦИЕЙ
  # НЕ РАБОТАЕТ!!! ЛОМАЕТ ВСЁ!!! TESTING...................................
  #  english_words.delete_at(english_words.index(sample_eng_word))

  counter += 1
end
