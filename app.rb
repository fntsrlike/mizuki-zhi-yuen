require './model/main'

SOURCE = File.join(__dir__, 'input.csv')
TARGET = File.join(__dir__, 'output.csv')

puts "Loading input file... #{SOURCE}"
puts 'Calculating...'

main = Main.new(SOURCE)
main.log
main.export(TARGET)

puts 'Done!'
puts "To check the output file: #{TARGET} "
puts ''
puts 'Press any key to finish the program...'
gets
