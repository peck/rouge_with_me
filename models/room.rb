class Room
  attr_accessor :connected_rooms
  attr_reader :row_range, :column_range
  def initialize(row_range:, column_range:, maze:, fill_space: true)
    @row_range = row_range
    @column_range = column_range
    @connected_rooms = []
    @maze = maze
    if !fill_space
      fail "row_range not allowed for container" if @row_range.size < @maze.room_min_rows
      fail "column_range not allowed for container" if @column_range.size < @maze.room_min_columns
      row_count = rand(@maze.room_min_rows..@maze.room_max_rows)
      column_count = rand(@maze.room_min_columns..@maze.room_max_columns)
      row_min, row_max= @row_range.to_a[0..row_count].minmax
      @row_range  = row_min..row_max
      column_min, column_max= @column_range.to_a[0..column_count].minmax
      @column_range  = column_min..column_max
    else
      fail "row_range not allowed for container" if @row_range.size < @maze.room_min_rows || @row_range.size > @maze.room_max_rows
      fail "column_range not allowed for container" if @column_range.size < @maze.room_min_columns || @column_range.size > @maze.room_max_columns
    end

  end

  def width
    @column_range.length
  end

  def height
    @row_range.length
  end

  def row_min
    @row_range.min
  end

  def row_max
    @row_range.max
  end

  def column_min
    @column_range.min
  end

  def column_max
    @column_range.max
  end


  def intersect(room:)
    min_tile, max_tile = surrounding_tiles.minmax
    other_min_tile, other_max_tile = room.tiles.minmax

    if other_min_tile.between?(min_tile, max_tile) || other_max_tile.between?(min_tile, max_tile)
      true
    else
      false
    end
  end

  def surrounding_tiles
    tiles.map(&:neighbors).flatten.uniq - tiles
  end

  def tiles
    @maze.tiles_in_area(col_range: @column_range, row_range: @row_range)
  end
end
