# Copyright (c) 2023, Paul Hartman
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.
require "set"

require_relative "window_handler"
require_relative "draw_primitives"

class GameOfLife
  include DrawingPrimitives
  attr_reader :all_tiles
  attr_accessor :paused
  def initialize(density_modifier = 20, tick_speed: 10, scale: 10, world_size: [800, 800], colors: {bg: :black, tiles: :white}, wrap: true, **kwargs)
    @tick_speed = tick_speed
    @paused = true
    @world = Set.new
    @tile_size = scale
    @wrap = wrap
    @colors = colors.map { |layer, color| [layer, Gosu::Color.const_get(color.upcase)] }.to_h
    @window = Window.new(**kwargs)

    @max_world_size = world_size
    @all_tiles = [(0...@max_world_size[0]).to_a, (0...@max_world_size[1]).to_a].reduce(&:product)
    @num_tiles = @all_tiles.size

    # Initialize world with some random cells.
    (@num_tiles / density_modifier).times { flip_tile random_tile }

    # Handle button presses.
    define_button_press_handlers
    # Define draw steps.
    define_draw_steps
    # Define update steps.
    define_update_steps
  end

  # Flips the tile at a given point. Usage: flip_tile([x_value, y_value])
  def flip_tile(coords)
    @world.include?(coords) ? @world.delete(coords) : (@world << coords)
  end

  def random_tile = [rand(0...@max_world_size[0]), rand(0...@max_world_size[1])]

  def neighbors_for(tile)
    x, y = *tile
    if @wrap
      x_minus_one, x_plus_one, y_minus_one, y_plus_one = x - 1, x + 1, y - 1, y + 1
      case x
      when 0
        x_minus_one = @max_world_size[0] - 1
      when @max_world_size[0] - 1
        x_plus_one = 0
      end

      case y
      when 0
        y_minus_one = @max_world_size[1] - 1
      when @max_world_size[1] - 1
        y_plus_one = 0
      end

      [
        [x, y_plus_one],
        [x, y_minus_one],
        [x_plus_one, y],
        [x_minus_one, y],
        [x_plus_one, y_plus_one],
        [x_plus_one, y_minus_one],
        [x_minus_one, y_plus_one],
        [x_minus_one, y_minus_one]
      ]
    else
      [
        [x, y + 1],
        [x, y - 1],
        [x + 1, y],
        [x - 1, y],
        [x + 1, y + 1],
        [x + 1, y - 1],
        [x - 1, y + 1],
        [x - 1, y - 1]
      ]
    end
  end

  # Update Game of Life world.
  def world_tick
    new_world = Set.new
    coords_to_check = @world.to_a + @world.flat_map { |x, y| neighbors_for [x, y] }.uniq
    coords_to_check.each do |tile|
      # puts "#{tile.inspect}: #{neighbors_for(tile).inspect}\n"
      case neighbors_for(tile).filter { @world.include? _1 }.size
      when 2
        if @world.include?(tile) then (new_world << tile) end
      when 3
        new_world << tile
      end
    end

    # NOTE: This line dereferences the existing @world Set.
    # For memory optimization purposes, may need to trigger
    # the GC afterwards.
    @world = new_world
    # GC.start
  end

  # Handle button presses.
  def define_button_press_handlers
    @window.define_button_press_handler(Gosu::KB_ESCAPE) { @window.close }
    @window.define_button_press_handler(Gosu::KB_SPACE) { @paused = !@paused }
    @window.define_button_press_handler(Gosu::KB_RETURN) { world_tick }

    # Camera controls
    @window.define_button_down_handler(Gosu::KB_LEFT) { @window.camera_x = [@window.camera_x - 2, 0].max }
    @window.define_button_down_handler(Gosu::KB_RIGHT) { @window.camera_x = [@window.camera_x + 2, (@max_world_size[0] * @tile_size) - @window.width].min }
    @window.define_button_down_handler(Gosu::KB_UP) { @window.camera_y = [@window.camera_y - 2, 0].max }
    @window.define_button_down_handler(Gosu::KB_DOWN) { @window.camera_y = [@window.camera_y + 2, (@max_world_size[1] * @tile_size) - @window.height].min }

    # Flip tiles that are clicked on
    @window.define_button_press_handler(Gosu::MS_LEFT) do
      tile = [
        (@window.mouse_x + @window.camera_x) / @tile_size,
        (@window.mouse_y + @window.camera_y) / @tile_size
      ]
      flip_tile tile
    end
  end

  # Define draw steps.
  def define_draw_steps
    @window.add_draw_step(:background) do |window|
      Gosu.draw_rect(
        @window.camera_x, @window.camera_y,
        @window.width, @window.height,
        @colors[:bg]
      )
    end

    @window.add_draw_step(:game_of_life_tiles) do |window|
      @world.each do |x_value, y_value|
        Gosu.draw_rect(
          x_value * @tile_size,
          y_value * @tile_size,
          @tile_size, @tile_size,
          @colors[:tiles]
        )
      end
    end

    @window.add_draw_step(:header) do |window|
      border_thickness = 4
      y_term = (@window.height * 0.2).round

      draw_rect_with_outline(@window.camera_x, @window.camera_y, @window.width, y_term, @colors[:box], border_thickness: border_thickness, border_color: @colors[:box_border])
    end
  end

  # Define update steps.
  def define_update_steps
    @window.add_update_step(:pause_gol) do |window|
      if (window.tick_count % (60 / @tick_speed).to_i == 0) && !@paused then world_tick end
    end
  end

  def show = @window.show

  def inspect = "#<GameOfLife>"
end
