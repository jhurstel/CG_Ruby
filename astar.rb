class Astar
  def initialize(start, destination)
    # create start and destination nodes
    @start_node = Astar_Node.new(start.x, start.y, -1, -1, -1, -1)
    @dest_node  = Astar_Node.new(destination.x, destination.y, -1, -1, -1, -1)

    @open_nodes   = [ @start_node ] # conatins all open nodes (nodes to be inspected)
    @closed_nodes = [] # contains all closed nodes (node we've already inspected)
  end

  # calc euclidian heuristic
  def heuristic(current_node, destination_node)
    return ( Math.sqrt( ((current_node.x - destination_node.x) ** 2) + ((current_node.y - destination_node.y) ** 2) ) ).floor
  end

  # calc cost
  def cost(current_node, destination_node)
    direction = direction(current_node, destination_node)

    return 10 if [2, 4, 6, 8].include?(direction) # south, west, east, north
    return 14
  end

  # determine direction (2, 4, 6, 8)
  def direction(current_node, destination_node)
    direction = [ destination_node.y - current_node.y,  # down/up
                  destination_node.x - current_node.x ] # negative: left, positive: right

    return 2 if direction[0] > 0 and direction[1] == 0 # south
    return 4 if direction[1] < 0 and direction[0] == 0 # west
    return 8 if direction[0] < 0 and direction[1] == 0 # north
    return 6 if direction[1] > 0 and direction[0] == 0 # east

    return 0 # default
  end

  # field passable? (current_node is an Astar_Node)
  def passable?(current_node)
    x = current_node.x
    y = current_node.y
    return (x >= 0 and x < WIDTH and y >= 0 and y < HEIGHT)
  end

  # expand node in all 4 directions (may be 8 wth diagonals or other logic)
  def expand(current_node)
    x = current_node.x
    y = current_node.y
    return [ Astar_Node.new(x, y-1, @closed_nodes.size-1, -1, -1, -1),  # north
             Astar_Node.new(x, y+1, @closed_nodes.size-1, -1, -1, -1),  # south
             Astar_Node.new(x+1, y, @closed_nodes.size-1, -1, -1, -1),  # east
             Astar_Node.new(x-1, y, @closed_nodes.size-1, -1, -1, -1) ] # west
  end

  def search
    while @open_nodes.size > 0 do
      # grab the lowest f(x)
      current_node = @open_nodes.min_by { |node| node.f }

      # check if we've reached our destination
      if current_node == @dest_node
        path = [ @dest_node ]

        # recreate the path
        while current_node.i != -1 do
          current_node = @closed_nodes[current_node.i]
          path.unshift(current_node)
        end

        return path
      end

      # remove the current node from open node list
      @open_nodes.delete(current_node)

      # and push onto the closed nodes list
      @closed_nodes << current_node

      # expand the current node
      neighbor_nodes = expand(current_node)
      neighbor_nodes.each do |neighbor|
        # check if the new node is passable or our destination
        if (passable?(neighbor) or (neighbor == @dest_node))
          # check if the node is already in closed nodes list
          next if @closed_nodes.include?(neighbor)

          # check if the node is in the open nodes list
          next if @open_nodes.include?(neighbor)

          # if not, setup costs!
          neighbor.g = current_node.g + cost(current_node, neighbor)
          neighbor.h = heuristic(neighbor, @dest_node)
          neighbor.f = neighbor.g + neighbor.h

          # and add it to open nodes list
          @open_nodes << neighbor
        end
      end
    end

    return [] # return empty path
  end

end

# Base coordinate
class Coord
  attr_accessor :x # x = x-position
  attr_accessor :y # y = y-position
  def initialize(x, y)
    @x = x
    @y = y
  end
  def ==(other)
      other.x == @x and other.y == @y
  end
  def !=(other)
      other.x != @x or other.y != @y
  end
end

# Astar node representation
class Astar_Node < Coord
  attr_accessor :i # i = parent index
  attr_accessor :g # g = cost from start to current node
  attr_accessor :h # h = cost from current node to destination
  attr_accessor :f # f = cost from start to destination going through the current node

  def initialize(x, y, i, g, h, f)
    super(x, y)
    @i = i
    @g = g
    @h = h
    @f = f
  end
  def ==(other)
      other.x == @x and other.y == @y
  end
  def !=(other)
      other.x != @x or other.y != @y
  end
  def to_s
      "(#{@x},#{@y})"
  end
end

#start_node  = Coord.new(1, 0)
#dest_node   = Coord.new(7, 3)
#result      = Astar.new(start_node, dest_node).search # returns Array
#STDERR.puts result.join(" ")
