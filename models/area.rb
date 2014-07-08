class Area
  attr_reader :point, :rows, :columns
  def initialize(point:, rows:, columns:)
    @point, @rows, @columns = point, rows, columns
  end

  def points
    points = []
    @rows.times do |r|
      @columns.times do |c|
        points << Point.new(row: @point.row + r, column:  @point.column + c)
      end
    end
    points
  end

  def intersect?(other)
    not (points & other.points).empty?
  end

  def random_sub_area(rows:, columns:)
    fail "area not that big" unless rows <= @rows && columns <= @columns
    Area.new(point: @point, rows: rows, columns: columns)
  end

  def buffer!
    @point = Point.new(row: @point.row - 1, column: @point.column - 1)
    @rows += 2
    @columns += 2
    self
  end

  def shrink!
    @point = Point.new(row: @point.row + 1, column: @point.column + 1)
    @rows -= 1
    @columns -= 1
    self
  end
end
