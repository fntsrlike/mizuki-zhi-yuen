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
    @echelon.validate
  end

  def log()
    puts '組別資訊如下：'
    @echelon.groups.each do |_, group|
      msg = "#{group.id} \t基本限額 #{group.capacity}，已登記 #{group.number} 名學生。"

      if group.number > group.capacity
        msg += "多 #{group.number - group.capacity} 名學生。"
      elsif  group.number < group.capacity
        msg += "未滿，尚能登記 #{group.capacity - group.number} 名學生。"
      end

      puts(msg)
    end

    puts ''
    puts '車位資訊如下：'
    @echelon.buses.each do |no, bus|
      puts "#{no} 號車，已登記 #{bus.size} 名學生"
    end

  end

  def export(output)
    CSV.open(output, "wb", encoding: 'big5') do |csv|
      header = ['班級', '座號', '姓名', '上午組別', '下午組別', '車次']
      csv << header

      @students.each do |id, student|
        begin
          row = [
              student.class,
              student.number,
              student.name,
              student.group_on(:morning).name,
              student.group_on(:afternoon).name,
              student.bus
          ]
          csv << row
        rescue => message
          student.name
          puts "#{id} 資料有誤，不會存入輸出資料中 (#{message})"
          next
        end
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