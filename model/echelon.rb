class Echelon
  PASSENGERS_PER_BUS = 36

  def initialize(structure, students, bus_number)
    @structure = structure
    @students = students
    @groups = structure.groups
    @place_buses_hash = {
        afternoon_a: {
            '1': [],
            '2': [],
            '3': []
        },
        afternoon_b: {
            '4': []
        }
    }
    @bus_number = @place_buses_hash[:afternoon_a].size + @place_buses_hash[:afternoon_b].size

    raise "車座位比總人數還少！" if @students.size > @bus_number * PASSENGERS_PER_BUS

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

    @place_capacity = {
        morning: @bus_number * PASSENGERS_PER_BUS,
        afternoon_a: @place_buses_hash[:afternoon_a].size * PASSENGERS_PER_BUS,
        afternoon_b: @place_buses_hash[:afternoon_b].size * PASSENGERS_PER_BUS
    }

    @passengers_counter = {
        morning: 0,
        afternoon_a: 0,
        afternoon_b: 0
    }

    @place_groups_hash = {
        morning: [],
        afternoon_a: [],
        afternoon_b: []
    }

    @groups.each do |_, group|
      @place_groups_hash[group.place].push(group)
    end
  end

  def distribute_order
    @students.each do |_, student|
      orders = Array.new(student.orders)
      orders.each do |group|
        next if orders.nil?
        next if student.distributed_on? group.period
        next if student.has_elective_category?(group.category)
        next if is_place_full? (group.place)

        if group.full?
          next if is_period_full?(group.period)
          next unless can_place_add_more?(group)
          next if will_place_full?(group.place) && is_all_group_full_at?(group.place)
        end

        @remainder[group.period] -= 1 if group.full?
        @passengers_counter[group.place] += 1

        group.add student
        student.elective group
        student.orders.shift
        break
      end
    end
  end

  def validate
  end

  def distribute_car
    # 以地方分組
    @place_groups_hash.each do |place, groups|
      next if place == :morning

      # 以組為排序去將學生一個個放入車輛中
      groups.each do |group|
        group.students.each do |student|
          # 將學生放入未滿的車輛中
          buses = @place_buses_hash[place]
          buses.each do |bus_number, bus_capacity|
            next if bus_capacity.size >= PASSENGERS_PER_BUS

            student.bus = bus_number
            bus_capacity.push(student)
            break
          end

          # 如果有學生沒有車，則發出警告
          if student.bus.empty?
            puts "[警告] #{student.class} #{student.name} 所屬的區域 #{group.place} 車位已滿！請自行到輸出檔案填寫該學生車次"
          end
        end
      end
    end
  end

  def is_period_full? (period)
    @remainder[period] == 0
  end

  def is_place_full? (place)
    @passengers_counter[place]  >= @place_capacity[place]
  end

  def will_place_full? (place)
    (@passengers_counter[place] + 1) >= @place_capacity[place]
  end

  def can_place_add_more? (group)
    (@capacity[group.period] * @place_groups_hash[group.place].size + 1) < @place_capacity[group.place]
  end

  def is_all_group_full_at? (place)
    are_another_group_full = true
    @place_groups_hash[place].each do |place_group|
      unless place_group.full?
        are_another_group_full = false
        break
      end
    end
    are_another_group_full
  end
end