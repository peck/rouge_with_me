require 'curses'
class Display
  include Curses

  def initialize()
    init_screen
    nonl
    cbreak
    noecho
  end

  def refresh_screen(displayables:)
    clear
    displayables.each do |dt|
      setpos(dt.x, dt.y)
      addstr(dt.icon)
    end
    refresh
  end

  def rows
    lines
  end

  def columns
    cols
  end

end
