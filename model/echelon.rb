class Echelon
  PASSENGERS_PER_CAR = 36

  def initialize(structure, students, car_number)
    @structure = structure
    @students = students
    @groups = structure.groups
    @car_number = car_number

    count_of_morning_groups = @structure.num_of_morning_group
    count_of_afternoon_groups = @structure.num_of_afternoon_group
    count_of_students = @students.size

    @capacity = {
      morning: (count_of_students / count_of_morning_groups).floor,
      afternoon: (count_of_students / count_of_afternoon_groups).floor
    }

    @remainder = {
      morning: count_of_students % count_of_morning_groups,
      afternoon: count_of_students % count_of_afternoon_groups
    }

    @groups.each do |_, group|
      group.capacity = @capacity[group.period]
    end
  end

  def distribute_order
    @students.each do |_, student|
      orders = Array.new(student.orders)
      orders.each do |group|
        student.orders.shift
        next if orders.nil?
        next if student.distributed_on? group.period
        next if student.has_elective_category?(group.category)

        if group.full?
          next if is_period_full? (group.period)
          @remainder[group.period] -= 1
        end

        group.add student
        student.elective group
        break
      end
    end
  end

  def distribute_car
    place_groups_hash = {
        afternoon_a: [],
        afternoon_b: []
    }

    place_buses_hash = {
        afternoon_a: {
          '1': [],
          '2': [],
          '3': []
        },
        afternoon_b: {
          '4': []
        }
    }

    @groups.each do |_, group|
      next if group.period === :morning
      place_groups_hash[group.place].push(group)
    end

    # 以地方分組
    place_groups_hash.each do |place, groups|

      # 以組為排序去將學生一個個放入車輛中
      groups.each do |group|
        group.students.each do |student|

          # 將學生放入未滿的車輛中
          buses = place_buses_hash[place]
          buses.each do |bus_number, bus_capacity|
            next if bus_capacity.size >= PASSENGERS_PER_CAR

            student.bus = bus_number
            bus_capacity.push(student)
            break
          end

          # 如果有學生沒有車，則發出警告
          if student.bus.empty?
            puts "[警告] #{student.class} #{student.name} 所屬的區域車位已滿！請自行到輸出檔案填寫該學生車次"
          end

        end
      end
    end
  end

  def is_period_full? (period)
    @remainder[period] == 0
  end
end