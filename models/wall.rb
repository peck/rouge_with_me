require_relative 'tile'
class Wall < Tile
  def initialize(*args)
    super
    @icon = "\033[31m#\033[0m"
  end
end
