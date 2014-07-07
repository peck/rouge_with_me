class BspNode
  attr_reader :row_range, :column_range, :parent
  attr_accessor :sibling, :room, :children

  def initialize(row_range:, column_range:, parent: nil)
    @row_range = row_range
    @column_range = column_range
    @parent = parent
    @children = []
    bisect unless level > 4
  end

  def leaf?
    children.empty?
  end


  def level
    level = 0
    parent_node = parent
    until parent_node.nil?
      parent_node = parent_node.parent
      level += 1
    end
    level
  end

  def room
    @room || children.map(&:room).sample
  end

  private
  def bisect
      hsh = {row_range: @row_range, column_range: @column_range}
      axis_key = hsh.keys.sample
      axis = hsh[axis_key]
      axis_size = axis.count

      split_at = axis_size * rand(0.3..0.7)

      axis_min_maxes= [axis.to_a[1..split_at-1], axis.to_a[split_at+1..-2]].map(&:minmax)

      hsh[:parent] = self
      axis_min_maxes.each do |min,max|
        return if min.nil? || max.nil?
        hsh[axis_key] = min..max
        @children << BspNode.new(**hsh)
      end
      l,r = *@children
      l.sibling = r
      r.sibling = l
    end

end
