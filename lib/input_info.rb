module InputInfo
  HEADER_ROW = 0

  # attr_reader :words

  # def initialize(column_words)
  #   @words_for_action = column_words
  #
  #   to_downcase
  # end

  # private

  def self.to_downcase(words)
    words.each { |english| english.downcase! } # Приводим к нижнему регистру

    delete_header(words)
  end

  def self.delete_header(words)
    words.delete_at(HEADER_ROW)
  end
end