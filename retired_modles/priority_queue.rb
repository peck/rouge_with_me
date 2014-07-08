class PriorityQueue
  def initialize()
    @list = []
  end

  def add(item)
    if existing = @list.find{|x| x == item}
      if item < existing
        @list.delete(existing)
        @list << item
        @list.sort
      end
    else
      index = @list.find_index {|x| x > item}
      if !index.nil?
        @list.insert(index, item)
      else
        @list << item
      end
    end
  end

  def next
    @list.shift
  end

  def empty?
    @list.empty?
  end

  private

  def sort
    @list.sort!
  end

end
