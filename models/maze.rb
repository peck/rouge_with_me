class Maze
  include Euclidean
  attr_reader :row_count, :column_count, :rooms, :room_columns_range, :room_rows_range

  def initialize(row_count: 10, column_count: 10, num_rooms: 10)
    @row_count = row_count
    @column_count = column_count
    @num_rooms = num_rooms
    @room_columns_range = 5..10
    @room_rows_range = 5..10
    @rooms = []
    @passageways = []
    @tile_hash = Hash.new()
    @row_count.times do |x|
      @column_count.times do |y|
        t = Tile.new(x: x, y: y, maze: self)
        @tile_hash[t.point] = t
      end
    end

    make_rooms_bsp

    @rooms.map(&:clear)

    start_room, end_room = @rooms.sample(2)
    start_tile = start_room.tiles.sample
    end_tile = end_room.tiles.sample
    fail "not path between start and end tile!" unless Pathway.new(start_tile: start_tile, end_tile: end_tile, method: :a_star, maze: self).points

    start_tile.icon = "🔺"
    end_tile.icon = "🔻"
  end

  def fit_room?(area:)
    area.rows >= @room_rows_range.min && area.columns >= @room_columns_range.min
  end

  def make_rooms_bsp
    tree = BspTree.new(row_range: (0..@row_count-1), column_range: (0..@column_count-1))

    tree.coalesce(min_row_size: @room_rows_range.min+1, min_column_size: @room_columns_range.min+1)

    leaves = tree.leaves

    leaves.each do |leaf|
      new_room = Room.new(area: leaf.to_area.shrink!, maze: self, fill_space: false)
      leaf.room = new_room
      @rooms << new_room
    end

    node_level = tree.nodes.group_by{|n| n.level}
    node_level.delete(0)
    node_level.keys.sort.reverse.each do |level|
      node_level[level].each do |node|
        sib = node.sibling
        connect_rooms(room1: node.room, room2: sib.room)
      end
    end
  end

  def surrounding_tiles(tiles: tiles)
    neighbors = tiles.map{|t| t.neighbors}.flatten.uniq
    neighbors - tiles
  end

  def to_s
    fail "NOT IMPLEMENTED"
  end

  def neighbors(tile, include_diagonals: true)
    cardinal_directions = {N: [-1, 0], S:[1, 0], E:[0, 1], W:[0,-1]}
    diagonal_directions = {NE: [-1, +1], SE:[1, 1], SW:[1, -1], NW:[-1,-1]}

    directions = cardinal_directions

    if include_diagonals
      directions.merge!(diagonal_directions)
    end

    directions.each do |direction, operations|
      x, y = operations.zip([tile.x, tile.y]).map{|e| e.inject(:+)}
      directions[direction] = @tile_hash[Point([x,y])]
    end
  end

  def random_tile
    @tile_hash[@tile_hash.keys.sample]
  end

  def tiles_from_coords(coords: coords)
    points = coords.map{|c| Point(c)}
    @tile_hash.values_at(*points)
  end

  def tiles_in_area(area: area)
    points = area.points
    @tile_hash.values_at(*points)
  end

  def tiles
    @tile_hash.values
  end

  def clear_tile(point)
    point = Point(point)
    fail "Tile does not exist in this maze" unless @tile_hash.has_key? point
    clear_tile = Opening.new(x: point.row, y: point.column, maze: self)
    old_tile = @tile_hash[point]
    @tile_hash[point] = clear_tile
    old_tile.neighbors.each do |n|
      n.dirty_neighbor = true
    end
  end

  private

  def connect_rooms(room1:, room2:)
    return if room1.connected_rooms.include? room2
    start_tile = room1.tiles.sample
    end_tile = room2.tiles.sample

    path = Pathway.new(start_tile: start_tile, end_tile: end_tile, maze: self)

    path.points.each do |t|
      clear_tile(t)
    end
    room1.connected_rooms << room2
    room2.connected_rooms << room1
    path
  end

  def make_rooms(allow_overlap: false, time_limit: 5)
    start_time = Time.now
    while @rooms.count < @num_rooms && Time.now - start_time < time_limit do
      make_room
    end
  end

  def make_room
    begin
      tl_tile = random_tile
      room_width = rand(@room_min_columns..@room_max_columns)
      room_height = rand(@room_min_rows..@room_max_rows)

      cols = (@room_min_columns..room_width).map{|col| col + tl_tile.y}.reject{|col| col >= @column_count - 1}
      rows = (@room_min_rows..room_height).map{|row| row + tl_tile.x}.reject{|row| row >= @row_count - 1}
    end until (cols.count.between? @room_min_columns, @room_max_columns) && (rows.count.between? @room_min_rows, @room_min_columns)

    new_room = Room.new(row_range: rows, column_range: cols, maze: self)

    area = new_room.area
    area.buffer!

    return if @rooms.map{|r| r.area.intersect? area}.include? true

    @rooms << new_room
  end
end
