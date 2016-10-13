require 'csv'
require_relative './echelon'
require_relative './group'
require_relative './student'
require_relative './structure'
require_relative './header_error'
require_relative './data_error'

class Main
  NUM_OF_CARS = 4
  ENCODING = 'BIG5'

  def initialize(source)
    # Input
    @students = {}
    @counter = 0


    fetch_data(source)

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
      begin
        @counter += 1

        if @counter  === 1
          @structure = Structure.new(row)
          next
        end

        parse_data(row)
      rescue HeaderError => message
        puts "[錯誤][標題列]： #{message}"
        puts "程序終止..."
        exit
      rescue DataError => message
        puts "[警告][第 #{@counter} 列]： #{message}"
      end
    end
  end

  def parse_data(row)
    raise DataError, "班級欄為空，視為空行" if row[0].to_s.empty?

    student = Student.new(row, @structure)
    raise DataError, "學生資料重複，不予分析" if @students.has_key?(student.id)

    @students[student.id] = student

  end
end