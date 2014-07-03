class Node
  attr_reader :tile, :parent

  def initialize(tile:, parent:)
    @tile = tile
    @parent = parent
  end

end
