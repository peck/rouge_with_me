Dir["./models/*.rb"].each {|file| require_relative file }
m = Maze.new(row_count: 50, column_count: 100, num_rooms: 10)
puts m
