class Student
  def initialize(row, structure)
    profiles = structure.row_to_profiles(row)
    @id = "#{profiles[:class]}_#{profiles[:number]}".to_sym
    @name = profiles[:name]
    @class = profiles[:class]
    @number = profiles[:number]
    @bus = ''

    @orders = structure.row_to_orders(row)
    @groups = []
  end

  def id
    @id
  end

  def name
    @name
  end

  def class
    @class
  end

  def number
    @number
  end

  def orders
    @orders
  end

  def bus
    @bus
  end

  def bus=(bus)
    @bus = bus
  end

  def group_on(period)
    @groups.each do |group|
      return group if group.is_on? period
    end
    nil
  end

  def group_at(place)
    @groups.each do |group|
      return group if group.place === place
    end
    nil
  end

  def elective(group)
    @groups.push(group)
  end

  def distributed_on? (period)
    @groups.each do |group|
      return true if group.is_on? period
    end
    false
  end

  def has_elective_category? (category)
    @groups.each do |group|
      return true if group.category == category
    end
    false
  end
end