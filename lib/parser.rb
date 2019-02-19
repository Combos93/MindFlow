require 'roo' # https://github.com/roo-rb/roo
require 'roo-xls' # https://github.com/roo-rb/roo-xls
require 'roo-google' # https://github.com/roo-rb/roo-google

class Parser
  FIRST_IN_ARRAY = 0
  HEADER_ROW = 1

  attr_reader :num_rows, :english, :russian

  def initialize(path_to_file)
    @path = path_to_file

    check_extension
  end

  def check_extension
    if @path.include?("docs.google.com/spreadsheets")
      # from_google_sheet
    else
      file_ext = File.extname(@path).split(".").last
    end

    case file_ext
    when "xlsx"
      from_xlsx
    when "ods"
      from_ods
    when "xls"
      from_xls
    when "xml"
      from_xml # TODO
    when "json"
      from_json # TODO
    else
      from_google_sheet
    end
  end

  def number_words
    "Найдено слов: #{@num_rows}"
  end

  private

  def prepare_words(array)
    array.each { |array| array.downcase! }
    array.delete_at(FIRST_IN_ARRAY)
  end

  def from_xlsx
    excel = Roo::Spreadsheet.open(@path)

    excel.each_with_pagename do |_name, sheet|
      @english = sheet.column(1)
      prepare_words(@english)

      @russian = sheet.column(2)
      prepare_words(@russian)
    end

    @num_rows = excel.last_row - HEADER_ROW
  end

  def from_ods
    ods = Roo::OpenOffice.new(@path, password: "")

    ods.each_with_pagename do |_name, ods|
      @english = ods.column(1)
      prepare_words(@english)

      @russian = ods.column(2)
      prepare_words(@russian)
    end

    @num_rows = ods.last_row - HEADER_ROW
  end

  def from_xls
    xls = Roo::Excel.new(@path)

    xls.each_with_pagename do |_name, xls|
      @english = xls.column(1)
      prepare_words(@english)

      @russian = xls.column(2)
      prepare_words(@russian)
    end

    @num_rows = xls.last_row - HEADER_ROW
  end

  def from_google_sheet
    # TODO
    url = Roo::Google.new(@path)

    url.each_with_pagename do |_name, url|
      @english = url.column(1)
      prepare_words(@english)

      @russian = url.column(2)
      prepare_words(@russian)
    end
  end

  def from_xml
    # TODO
  end

  def from_json
    # TODO
  end
end
