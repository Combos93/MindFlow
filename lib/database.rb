require 'sqlite3'

class Database

  attr_reader :result, :eng_words, :rus_words, :num_rows

  def initialize(database)
  @current_database  = database

    @result = []

    find_tables
  end

  def find_tables
    db = SQLite3::Database.open(@current_database)
    @result = db.execute("SELECT name FROM sqlite_master WHERE type='table'")
    db.close

    if @result == nil
      @result = 'Таблиц в базе не нашлось.. =('
    else
      @result
    end
  end

  def parsing(table)
    table = table.join('')

    db = SQLite3::Database.open(@current_database)
    @eng_words = db.execute("SELECT Eng FROM #{table}")
    @rus_words = db.execute("SELECT Rus FROM #{table}")
    db.close

    prepare_words(@eng_words)
    prepare_words(@rus_words)

    @num_rows = @eng_words.size
  end

  def count_rows
    "Найдено слов: #{@num_rows}"
  end

  def prepare_words(array)
    array.map! { |word| word.join("") }
    array.map { |word| word.downcase! }
  end
end
