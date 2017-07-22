require 'pp'  # DEBUG


class ASCIIGraph
  def initialize(**options)
    @width = options[:width] || 80
    @height = options[:height] || 30
    @background_char = '.'
    @line_char = 'x'
    @ticks_char = '-'
    @knob_char = '@'
    @frame_char = 'o'
    @top_padding_height = 4
    @bottom_padding_height = 4
    @left_padding_width = 4
    @right_padding_width = 4
    initialize_screen()
  end

  #========================================================================
  # Public
  #========================================================================
  public

  def plot(data, **options)
    # Options
    options = {
      :line => @line_char, :ticks => @ticks_char,
      :frame => @frame_char, :background => @background_char,
      :knob => @knob_char, :tags => true,}.merge(options)
    do_draw_line = true
    do_draw_line = false if options[:line] == false ||
      options[:line] == nil
    line_char = options[:line]
    do_draw_frame = true
    do_draw_frame = false if options[:frame] == false ||
      options[:frame] == nil
    frame_char = options[:frame] || @frame_char
    do_draw_tags = options[:tags]
    @background_char = options[:background]
    @knob_char = options[:knob]
    do_draw_ticks = false
    do_draw_ticks = true if options[:ticks] == true

    # clear({:char => @background_char})

    PP.pp(data)  # DEBUG
    unscaled_data = data.clone()
    scale!(data)
    PP.pp(data)  # DEBUG

    step = @width / data.length
    draw_top_padding() if do_draw_tags
    # Draw lines.
    draw_lines({:data => data, :char => line_char, :step => step}) if
      do_draw_line
    # Draw knobs.
    draw_knobs({:data => data, :step => step})
    # Draw tags.
    draw_tags({:data => data, :step => step, :unscaled_data =>
                unscaled_data}) if do_draw_tags

    # Padding
    if do_draw_tags
      draw_left_padding()
      draw_right_padding()
    end

    # Draw ticks.
    draw_ticks({:data => data}) if do_draw_ticks

    draw_bottom_padding() if do_draw_tags

    # Draw frame.
    draw_frame(frame_char) if do_draw_frame

    print()
  end

  #========================================================================
  # Private
  #========================================================================
  private

  def draw_ticks(**options)
    data = options[:data] || []
    data.each_with_index do |v, i|
      @width.times do |x|
        pos = (@height - v) * @width + x
        @screen[pos] = @ticks_char if @screen[pos] == @background_char
      end
    end
  end

  def draw_frame(char)
    @width += 2
    @height += 2
    @height.times do |y|
      # Left
      @screen.insert(y * @width, char)
      # Right
      @screen.insert(y * @width + @width - 1, char)
    end
    @width.times do |x|
      # Top
      @screen.insert(x, char)
    end
    @width.times do |x|
      # Bottom
      @screen.insert((@height - 1) * @width + x, char)
    end
  end

  def draw_left_padding()
    n = @left_padding_width
    @width += n
    @height.times do |y|
      n.times do
        @screen.insert(y * @width, @background_char)
      end
    end
  end

  def draw_right_padding()
    n = @right_padding_width
    @width += n
    @height.times do |y|
      n.times do
        @screen.insert(y * @width + @width - n, @background_char)
      end
    end
  end

  def draw_bottom_padding()
    n = @bottom_padding_height
    @height += n
    (n * @width).times do
      @screen << @background_char
    end
  end

  def draw_top_padding()
    n = @top_padding_height
    @height += n
    (n * @width).times do
      @screen.unshift(@background_char)
    end
  end

  def draw_tags(**options)
    data = options[:data] || []
    step = options[:step] || []
    unscaled_data = options[:unscaled_data] || []
    yy = 0
    data.each_with_index do |v, i|
      data[i - 1] <= data[i] ? yy = -1 : yy = 1
      yy = -1 if v <= 2
      @screen[(@height - v + yy) * @width + i * step] = '|'
      unscaled_data[i].to_s.split('').each_with_index do |c, j|
        @screen[(@height - v + (yy * 2)) * @width + i * step + j] = c
      end
    end
  end

  def draw_knobs(**options)
    data = options[:data] || []
    step = options[:step] || []
    data.each_with_index do |v, i|
      @screen[(@height - v) * @width + i * step] = @knob_char
    end
  end

  def draw_lines(**options)
    data = options[:data] || []
    char = options[:char] || 'x'
    step = options[:step] || 1

    data.each_with_index do |v, i|
      begin
        # draw_line(char, i * step, v, i * step + step, data[i + 1])
        y0 = @height - v
        y1 = @height - data[i + 1]
        draw_line(char, i * step, y0, i * step + step, y1)
      rescue Exception => e
        # Draw nothing, if drawing is not possible.
      end
    end
  end

  def draw_line(char, x0, y0, x1, y1)
    steep = (y1-y0).abs > (x1-x0).abs
    if steep
      x0,y0 = y0,x0
      x1,y1 = y1,x1
    end
    if x0 > x1
      x0,x1 = x1,x0
      y0,y1 = y1,y0
    end
    deltax = x1-x0
    deltay = (y1 - y0).abs
    error = (deltax / 2).to_i
    y = y0
    ystep = nil
    if y0 < y1
      ystep = 1
    else
      ystep = -1
    end
    for x in x0..x1
      if steep
        # if (x >= 0 && x < @height) && (y >= 0 && y < @width)
        #   @screen[x * @width + y] = char
        # end
        # @screen[x * @width + y] = char
        if (x >= 0 && x < @height) && (y >= 0 && y < @width)
          @screen[x * @width + y] = char
        end
      else
        # if (x >= 0 && x < @width) && (y >= 0 && y < @height)
        #   @screen[y * @height + x] = char
        # end
        # @screen[y * @width + x] = char
        if (x >= 0 && x < @width) && (y >= 0 && y < @height)
          @screen[y * @width + x] = char
        end
      end
      error -= deltay
      if error < 0
        y += ystep
        error += deltax
      end
    end
  end

  def print()
    s = ''
    @height.times do |y|
      s << @screen[(y * @width)..(y * @width + @width - 1)].join()
      s << "\n"
    end
    puts(s)
  end

  def scale!(data)
    old_min = data.min()
    old_max = data.max()
    old_range = (old_max - old_min)

    new_min = 1
    new_max = @height
    new_range = (new_max - new_min)

    data.each_with_index do |value, i|
      data[i] = (((data[i] - old_min) * new_range) / old_range) + new_min
    end
  end

  def clear(**options)
    char = options[:char] || '.'
    @height.times do |y|
      @width.times do |x|
        @screen[y * @width + x] = char
      end
    end
  end

  def initialize_screen()
    @screen = Array.new(@height * @width)
    clear({:char => @background_char})
  end
end


graph = ASCIIGraph.new()
# data =
#   [
#    30,
#    234,
#    4,
#    123,
#    200,
#    89,
#    189,
#    10,
#   ].sort().reverse()
data = []
10.times { data << rand(500) }
data = data#.sort().reverse()
graph.plot(data, {:line => 'i', :frame => false, :tags => true})

other_data = []
10.times { other_data << rand(30) }
other_data = other_data.sort().reverse()
graph.plot(other_data, {:line => 'k', :frame => false, :tags => true})
