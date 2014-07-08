class Point
  include Comparable
  attr_reader :row, :column
  def initialize(row:, column:)
    @row, @column = row, column
  end

  def to_str
    "#{row}_#{column}"
  end

  def <=>(other)
    [@row, @column] <=> [other.row, other.column]
  end

  def eql?(other)
    other.is_a?(Point) && @row == other.row && @column == other.column
  end

  def hash
    [@row, @column].hash
  end
end
