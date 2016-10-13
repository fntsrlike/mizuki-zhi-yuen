 class Structure
  COL_NAME = 3
  COL_CLASS = 1
  COL_NUMBER = 2
  COL_ORDER_MIN = 4
  COL_ORDER_MAX = 16

  def initialize(header)
    @columns = Array.new(header)
    @group_columns = Array.new(header[(COL_ORDER_MIN-1) .. (COL_ORDER_MAX-1)])

    @groups = {}
    @group_periods = {
      morning: [],
      afternoon_a: [],
      afternoon_b: []
    }
    @group_columns.each do |column|
      group = column_to_group(column)

      @group_periods[group.place].push(group)
      @groups[group.name] = group
    end
  end

  # Getters
  def columns
    @columns
  end

  def groups
    @groups
  end

  def num_of_morning_group
    @group_periods[:morning].size
  end

  def num_of_afternoon_group
    @group_periods[:afternoon_a].size + @group_periods[:afternoon_b].size
  end

  def num_of_afternoon_a_group
    @group_periods[:afternoon_a].size
  end

  def num_of_afternoon_b_group
    @group_periods[:afternoon_b].size
  end

  # Methods
  def row_to_profiles (row)
    {
      name: row[COL_NAME-1],
      class: row[COL_CLASS-1],
      number: row[COL_NUMBER-1]
    }
  end

  def row_to_orders (row)
    data = row[(COL_ORDER_MIN-1) .. (COL_ORDER_MAX-1)]
    data = data.map { |value| value.to_i }

    orders = []
    data.each_with_index do | value, index |
      order = value === 0 ? orders.size : value
      order = orders[order].nil? ? order : order+1

      group_name = get_name_of_group(index)
      orders.insert(order, @groups[group_name])
    end
    orders = orders.compact
    raise "志願序解析失敗" if orders.size != data.size
    orders
  end

  def column_to_group (column)
    data = column.to_s.match(/(\D+)(\d?)\((\W+)(\w?)\)/)
    raise HeaderError , '志願序欄位名稱定義有誤' if data.nil?

    category = data[1]
    name = data[1] + data[2]
    period_time = data[3].to_s
    period_type = data[4].to_s.downcase

    if period_time === '早'
      period = :morning
    else
      raise HeaderError , "欄位「#{column}」沒有定義下午的類別！" if period_type.empty?
      period = "afternoon_#{period_type}".to_sym
    end

    Group.new(name, category, period)
  end

  def get_name_of_group(order_number)
    column_name = @group_columns[order_number]
    column_name.to_s.match(/(\D+\d?)\((\W+)(\w?)\)/)[1]
  end
end