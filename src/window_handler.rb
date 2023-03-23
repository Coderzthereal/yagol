# Copyright (c) 2023, Paul Hartman
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.
require "gosu"

require_relative "button_handler"

class GameOfLife
  class Window < Gosu::Window
    include ButtonHandler

    attr_reader :frame, :tick_count, :camera_pos
    attr_accessor :camera_x, :camera_y, :scale

    def initialize(width: 640, height: 480, resizable: true)
      super width, height
      self.resizable = resizable
      self.caption = "Game of Life"

      @frame, @tick_count = 0, 0
      @camera_x, @camera_y = 0, 0 #-2 * width, -2 * height
      @draw_steps = {}
    end

    # Draws the world to the screen and updates the frame count.
    def draw
      @frame += 1

      Gosu.translate(-@camera_x, -@camera_y) { @draw_steps.each { |name, step| step[self] } }
    end

    # Adds a block to run during the draw sequence.
    def add_draw_step(name, &step) = @draw_steps[name] = step

    # Overrides #mouse_x and #mouse_y to return integers.
    def mouse_x = super.to_i

    def mouse_y = super.to_i
  end
end
