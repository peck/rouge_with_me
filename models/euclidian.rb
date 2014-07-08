module Euclidean
  module_function
  def Point(*args)
    case args.first
    when Point
      args.first
    when Array
      Point.new(row: args.first[0], column: args.first[1])
    when ->(arg){ arg.respond_to?(:to_point)}
      args.first.to_point
    else
      fail TypeError, "Cannot convert #{args.inspect} to Point"
    end
  end
end
