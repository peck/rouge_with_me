# encoding: UTF-8
require 'pry'
Dir["./models/*.rb"].each {|file| require_relative file }

disp = Display.new()
#
inp = Input.new


begin
  m = Maze.new(row_count: 40, column_count: 100, num_rooms: 10)
  tiles = m.tiles
  display_tiles = tiles.map{|t| DisplayTile.new(t)}
  disp.refresh_screen(displayables: display_tiles)
end while inp.get
#

