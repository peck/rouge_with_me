class Maze
  attr_reader :row_count, :column_count, :rooms, :room_min_rows, :room_max_rows, :room_min_columns, :room_max_columns

  def initialize(row_count: 10, column_count: 10, num_rooms: 10)
    @row_count = row_count
    @col_count = column_count
    @num_rooms = num_rooms
    @room_min_columns = 5
    @room_max_columns = 10
    @room_min_rows = 5
    @room_max_rows = 10
    @rooms = []
    @passageways = []
    @tile_hash = Hash.new()
    Array.new(@row_count) do |x|
      Array.new(@col_count) do |y|
        t = Tile.new(x: x, y: y, maze: self)
        @tile_hash[t.key_str] = t
      end
    end


    make_rooms_bsp

    #make_rooms

    start_room, end_room = @rooms.sample(2)
    start_tile = start_room.tiles.sample
    end_tile = end_room.tiles.sample

    #begin
    #  r1, r2 = @rooms.sample(2)
    #  @passageways << connect_rooms(room1: r1, room2: r2)
    #end until (@rooms.map{|r| r.connected_rooms.count}.min != 0) && (!Pathway.new(start_tile: start_tile, end_tile: end_tile, method: :a_star, maze: self).tiles.nil?)
    # @passageways.compact!

    #surrounds = surrounding_tiles(tiles: @passageways.map{|p| p.tiles}.flatten + @rooms.map{|r| r.tiles}.flatten)
    #surrounds.each do |s|
    # make_wall(s)
    #end
    #
    start_tile.icon = "🔺"
    end_tile.icon = "🔻"
  end

  def make_rooms_bsp
    tree = BspTree.new(row_range: (0..@row_count-1), column_range: (0..@col_count-1))

    tree.coalesce(min_row_size: @room_min_rows, min_column_size: @room_min_columns)

    leaves = tree.leaves

    leaves.each do |leaf|
      rows = leaf.row_range
      cols = leaf.column_range

      new_room = Room.new(row_range: rows, column_range: cols, maze: self, fill_space: false)
      leaf.room = new_room
      @rooms << new_room
      new_room.tiles.each do |tile|
        clear_tile(tile)
      end
    end

    leaves.each do |l|
      sib = l.sibling
      connect_rooms(room1: l.room, room2: sib.room)
    end

    (tree.nodes - leaves - [tree.root]).each do |n|
      sib = n.sibling
      connect_rooms(room1: n.room, room2: sib.room)
    end

  end

  def surrounding_tiles(tiles: tiles)

    neighbors = tiles.map{|t| t.neighbors}.flatten.uniq
    surrounding = neighbors - tiles
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
      directions[direction] = @tile_hash["#{x}_#{y}"]
    end
  end

  def random_tile
    @tile_hash[@tile_hash.keys.sample]
  end

  def tiles_from_coords(coords: coords)
    @tile_hash.values_at(*(coords.map{|x| x.join("_")}))
  end

  def tiles_in_area(row_range: , col_range:)
    tile_coords = row_range.to_a.product col_range.to_a
    tile_keys = tile_coords.map{|x| x.join "_"}
    @tile_hash.values_at(*tile_keys)
  end

  def tiles
    @tile_hash.values
  end

  private

  def connect_rooms(room1:, room2:)
    return if room1.connected_rooms.include? room2
    start_tile = room1.tiles.sample
    end_tile = room2.tiles.sample

    path = Pathway.new(start_tile: start_tile, end_tile: end_tile, maze: self)

    path.tiles.each do |t|
      clear_tile(t)
    end
    room1.connected_rooms << room2
    room2.connected_rooms << room1
    path
  end

  def make_rooms()
    start_time = Time.now
    while @rooms.count < @num_rooms && Time.now - start_time < 5 do
      make_room
    end
  end

  def make_room
    begin
    tl_tile = random_tile
    room_width = rand(@room_min_columns..@room_max_columns)
    room_height = rand(@room_min_rows..@room_max_rows)

    cols = (@room_min_columns..room_width).map{|col| col + tl_tile.y}.reject{|col| col >= @col_count - 1}
    rows = (@room_min_rows..room_height).map{|row| row + tl_tile.x}.reject{|row| row >= @row_count - 1}
    end until (cols.count.between? @room_min_columns, @room_max_columns) && (rows.count.between? @room_min_rows, @room_min_columns)


    tile_coords = rows.product cols
    tile_keys = tile_coords.map{|tc| tc.join("_")}
    room_tiles = @tile_hash.values_at(*tile_keys)

    new_room = Room.new(row_range: rows, column_range: cols, maze: self)

    #@rooms.each do |room|
    #  if room.intersect(room: new_room)
    #    return
    #  end
    #end


    room_tiles.each do |tile|
      clear_tile(tile)
    end

    @rooms << new_room
  end

  def clear_tile(tile)
    fail "Tile does not exist in this maze" unless @tile_hash.has_key?(tile.key_str)
    clear_tile = Opening.new(x: tile.x, y: tile.y, maze: self)

    @tile_hash[clear_tile.key_str] = clear_tile
    tile.neighbors.each do |n|
      n.dirty_neighbor = true
    end
  end

  def make_wall(tile)
    fail "Tile does not exist in this maze" unless @tile_hash.has_key?(tile.key_str)
    wall_tile = Wall.new(x: tile.x, y: tile.y, maze: self)

    @tile_hash[wall_tile.key_str] = wall_tile
    tile.neighbors.each do |n|
      n.dirty_neighbor = true
    end
  end


end
