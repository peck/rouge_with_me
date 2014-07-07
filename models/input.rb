require 'curses'

class Input
  include Curses
  def initialize

  end

  def get
    getch
  end
end
