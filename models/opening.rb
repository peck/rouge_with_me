require_relative 'tile'
class Opening < Tile
  def initialize(*args)
    super
    @passable_cost = 0
    @icon = "▪️"
  end

end
