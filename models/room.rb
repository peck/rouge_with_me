class Room
  include Euclidean
  attr_accessor :connected_rooms
  attr_reader :area
  def initialize(area:, maze:, fill_space: true)
    @area = area
    @connected_rooms = []
    @maze = maze
    fail "area provided does not have large enough dimensions for this maze"  unless @maze.fit_room?(area: @area)
    return if fill_space
    row_max = [@area.rows, @maze.room_rows_range.max].min
    col_max = [@area.columns, @maze.room_columns_range.max].min
    room_rows = (@maze.room_rows_range.min..row_max).to_a.sample
    room_columns = (@maze.room_columns_range.min..col_max).to_a.sample
    @area = area.random_sub_area(rows: room_rows, columns: room_columns)

  end

  def clear
    points.each do |p|
      @maze.clear_tile(p)
    end
  end

  def points
    @area.points
  end

  def width
    @column_range.length
  end

  def height
    @row_range.length
  end

  def intersect?(room)
    area_with_buffer = area.buffer!
    area_with_buffer.intersect? room.area
  end

  def surrounding_tiles
    tiles.map(&:neighbors).flatten.uniq - tiles
  end

  def tiles
    @maze.tiles_in_area(area: area)
  end

end
