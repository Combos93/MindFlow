require 'roo' # https://github.com/roo-rb/roo
require 'roo-xls' # https://github.com/roo-rb/roo-xls

class Parser
  HEADER_ROW = 0

  attr_reader :num_rows, :english, :russian

  def initialize(path_to_file)
    @path = path_to_file

    # check_extension
    from_xlsx
  end

  # https://rubyinrails.com/2014/02/02/ruby-get-file-extension-from-string-example/

  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # def check_extension
  #   if extension == 'xlsx'
  #     from_xlsx
  #   elsif extension == 'ods'
  #     from_ods
  #   else
  #     from_xls
  #   end
  #
  #   @path = "#{__dir__}/data/EngRus.#{extension}"
  # end

  def number_words
    "Найдено слов: #{@num_rows - 1}"
  end

  private

  def from_xlsx
    excel = Roo::Spreadsheet.open(@path)
    worksheets = excel.sheets

    excel.each_with_pagename do |_name, sheet|
      @english = sheet.column(1)
      @english.each { |english| english.downcase! }
      @english.delete_at(HEADER_ROW)

      # @english = InputInfo.new(sheet.column(1))

      @russian = sheet.column(2)
      @russian.each { |russian| russian.downcase! }
      @russian.delete_at(HEADER_ROW)

      # @russian = InputInfo.new(sheet.column(2))
    end

    worksheets.each do |worksheet|
      @num_rows = 0

      excel.sheet(worksheet).each_row_streaming do |row|
        row.map {|cell| cell.value}
        @num_rows += 1

        if row == []
          @num_rows -=1
          break
        end
      end
    end
  end

  def from_ods
    # TODO
    #
    # ods = Roo::OpenOffice.new(FILE_PATH, password: "") # stash for OpenOffice Support
    # a = ods.column(1)                                  #
    # b = ods.column(2)                                  #
    # a.delete_at(HEADER_ROW)                            #
    # b.delete_at(HEADER_ROW)                            #
  end

  def from_xls
    # TODO
    #
    # sheet = Roo::Excel.new('/Users/gturner/downloads/table.xls')
    # stash for Excel-2003 Support
  end
end