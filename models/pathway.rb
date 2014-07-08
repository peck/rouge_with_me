require 'set'
require 'priority_queue'
class Pathway

  def initialize(start_tile:, end_tile:, maze:, method: :a_star)
    @maze = maze
    @method = method
    @start_tile = start_tile
    @end_tile = end_tile
    @coords = []
    send(@method)
  end

  def points
    @coords
  end

  protected

  def a_star(with_tracing: false)
    if with_tracing
      @start_tile.icon = "@"
      @end_tile.icon = "&"
    end
    closed_set = Set.new
    open_queue = PriorityQueue.new

    heur = ->(t1, t2){t1.distance(tile: t2)}
    n = AsNode.new(tile: @start_tile, g: 0, h: heur.call(@start_tile, @end_tile), parent: nil )
    open_queue.push n, n.f

    begin
      current_node, priority = open_queue.delete_min
      closed_set.add(current_node)

      if with_tracing
        current_node.tile.icon = "$"
        puts @maze
      end

      if current_node.tile == @end_tile
        begin
          @coords << current_node.point
          current_node = current_node.parent
        end while current_node != nil
        return
      end
      neighbors = current_node.tile.neighbors
      nodes = neighbors.map{|n| AsNode.new(tile: n, g: current_node.g + current_node.tile.distance(tile: n) + n.passable_cost, h: heur.call(n, @end_tile), parent: current_node)}
      nodes.each do |n|
        if open_queue.has_key?(n)
          existing, f = open_queue.delete(n)
          n = [existing, n].min
        end
        open_queue.push(n, n.f) unless closed_set.include? n
      end

    end while !open_queue.empty?
    fail "no path found, wtf. we have no obstacles"
  end

end
