require 'csv'
require_relative './echelon'
require_relative './group'
require_relative './student'
require_relative './structure'
require_relative './data_error'

class Main
  NUM_OF_CARS = 4
  ENCODING = 'BIG5'

  def initialize(source)
    # Input
    @students = {}
    @counter = 1

    begin
      fetch_data(source)
    rescue DataError => message
      puts "第 #{@counter} 列的資料發生錯誤： #{message}"
    end

    # Calculate
    @echelon = Echelon.new(@structure, @students, NUM_OF_CARS)
    @echelon.distribute_order
    @echelon.distribute_order
    @echelon.distribute_car
  end

  def export(output)
    CSV.open(output, "wb", encoding: 'big5') do |csv|
      header = ['班級', '座號', '姓名', '上午組別', '下午組別', '車次']
      csv << header
      @students.each do |_, student|
        row = [
            student.class,
            student.number,
            student.name,
            student.group_on(:morning).name,
            student.group_on(:afternoon).name,
            student.bus
        ]
        csv << row
      end
    end
  end

  def fetch_data(source)
    CSV.foreach(source, encoding: 'big5:utf-8') do |row|
      if @counter  === 1
        @structure = Structure.new(row)
        @counter += 1
        next
      end

      student = Student.new(row, @structure)

      raise DataError, "學生資料重複" if @students.has_key?(student.id)

      @students[student.id] = student
      @counter += 1
      next
    end
  end
end