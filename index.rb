require 'roo'
require_relative 'methods.rb'

if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end


excel = Roo::Spreadsheet.open './EngRus.xlsx'
worksheets = excel.sheets

english_words = []
russian_words = []
answers = []


excel.each_with_pagename do |_name, sheet|

  english_words = sheet.column(1) #Реализовал парсинг eng
  russian_words = sheet.column(2) #Реализовал парсинг rus

  russian_words.delete_at(0)
  english_words.delete_at(0)
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

#TODO while number != fixnum - если не число - то ввести заного! ;)

# puts rus.to_s                            # Посмотреть русские слова
# puts
# puts eng.to_s                            # Посмотреть английские слова

counter = 1
while counter <= how_many_words
  # выбрать случайное английское слово; одно; написать игроку
  puts sample_eng_word = english_words.sample
  # номер индекса случайного английского слова
  index_sample_eng_word = english_words.index(sample_eng_word) + 2

  # случайный русский набор ответов: русский набор слов(выбранное количество ответов - 1)
  sample_russian_set = russian_words.sample(how_many_answers)
  # случайный русский набор ответов << добавим сюда верное англ. слово; по индексу, конечно, = англискому индексу.
  sample_russian_set << russian_words[index_sample_eng_word - 2]

  puts
  # случайный русский набор ответов перемешаем и уберём дубликаты
   sample_russian_set.shuffle!.uniq
  puts

  # случайный русский набор ответов после uniq`a НЕ РАВЕН выбранному количеству ответов (вдруг!)
  # то берём случайное русское слово и добавляем в набор
  if sample_russian_set.length != (how_many_answers - 1)
    sample_russian_set << russian_words.sample
    answers << sample_russian_set
  end
  sample_russian_set.shuffle!
  answers = sample_russian_set ###################
puts answers

  puts "Вариант ответа: (пишем полностью)"
  our_answer = STDIN.gets.chomp.to_s
  puts

  if answers.include?(our_answer)
    puts "Правильный ответ! =)"
  else
    puts "Не правильный ответ! =/"
  end

  counter += 1
end

# for item in answers do
#   div = item.split(/ /)
# end
# p div

# " now's  the time".split(/ /)   #=> ["", "now's", "", "the", "time"]   # TODO Реализуем разбитие ответа, а точнее массива ответа (если не 1 слово) на несколько (<- из RubyDoc`a)
# TODO Строки 84-87 работают. Надо очистить от ошибок эксельку и реализовывать ответы по одному слову из массива ответа.
# TODO А ещё.... ВОЗЬМИ И ОТРЕФАКТОРИ КОД НАКОНЕЦ И УБЕРИ НЕНУЖНОЕ!!!!!
