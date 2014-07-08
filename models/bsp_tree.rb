class BspTree
  attr_reader :root
  def initialize(row_range:, column_range:, levels:5)
    @root = BspNode.new(row_range: row_range, column_range: column_range)

  end

  def leaves
    nodes.select{|n| n.leaf?}
  end

  def nodes
    nodes = []
    to_visit_list = []
    curr_node = @root
    begin
      to_visit_list.push *curr_node.children
      nodes << curr_node
      curr_node = to_visit_list.pop
    end while !curr_node.nil?
    nodes
  end

  def delete_node(node)
    fail "node is not a leaf" unless node.leaf?
    node.parent.children = []
    sib = node.sibling
    sib.sibling = nil unless sib.nil?
    node.sibling = nil
  end

  def coalesce(min_row_size:, min_column_size:)
    begin
      keep_coalescing = false
      leaves.each do |l|
        if (l.row_range.size < min_row_size) || (l.column_range.size < min_column_size)
          keep_coalescing = true
          delete_node(l)
        end
      end
    end while keep_coalescing
  end
end
