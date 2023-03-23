# Copyright (c) 2023, Paul Hartman
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.
require_relative "../src/window_handler"

window = GameOfLife::Window.new(width: 1600, height: 1000, resizable: false)

window.add_draw_step do |window|
  window.draw_rect(0, 0, 1600, 1000, Gosu::Color::WHITE)
end

window.show
