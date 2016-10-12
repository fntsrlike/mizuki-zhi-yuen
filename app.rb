require './model/main'


SOURCE = File.dirname(__FILE__) + '/orders.csv'
TARGET = File.dirname(__FILE__) + '/result.csv'

puts "輸入檔案： #{SOURCE}"
puts '開始運算...'

main = Main.new(SOURCE)
main.export(TARGET)

puts "執行完畢，請查看檔案： #{TARGET} "
gets
