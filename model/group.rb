class Group
  def initialize(name, category, place)
    @name = name
    @category = category
    @capacity = 0
    @place = place
    @students = []
  end

  def id
    place = "早" if @place === :morning
    place = "午A" if @place === :afternoon_a
    place = "午B" if @place === :afternoon_b
    "#{@name} \t(#{place})"
  end

  def number
    @students.size
  end

  def students
    @students
  end

  def name
    @name
  end

  def category
    @category
  end

  def capacity
    @capacity
  end

  # :morning
  # :afternoon_a
  # :afternoon_b
  def place
    @place
  end

  # :morning
  # :afternoon
  def period
    @place == :morning ? :morning : :afternoon
  end

  def full?
    @students.size >= @capacity
  end

  def is_on? (the_period)
    period === the_period
  end

  def add (student)
    @students.push(student)
  end

  def capacity= (number)
    @capacity = number
  end
end