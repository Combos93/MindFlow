module Option
  def self.sklonenie(questions, otvet, otveta, otvetov)
    ostatok = questions % 10

    return " #{otvet}" if ostatok == 1
    return " #{otveta}" if ostatok.between?(2, 4)
    return " нет #{otvetov}" if questions == 0

    " #{otvetov}"
  end
end