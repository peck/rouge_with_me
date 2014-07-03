class Room
  attr_accessor :connected_rooms
  attr_reader :row_range, :col_range
  def initialize(rows:, cols:, maze:)
    @row_range = rows.min..rows.max
    @col_range = cols.min..cols.max
    @connected_rooms = []
    @maze = maze
  end

  def width
    @col_range.length
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

  def col_min
    @col_range.min
  end

  def col_max
    @col_range.max
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
    @maze.tiles_in_area(col_range: @col_range, row_range: @row_range)
  end
end
