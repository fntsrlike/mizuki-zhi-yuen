class DataError < StandardError
  def initialize(msg="不明資料錯誤")
    super(msg)
  end
end