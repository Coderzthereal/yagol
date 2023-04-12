# Copyright (c) 2023, Paul Hartman
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.
require "bundler/setup"
require "gosu"

module DrawingPrimitives
  def draw_rect_with_outline(x, y, width, height, c, border_thickness:, border_color:)
    # Background of rect
    Gosu.draw_rect(x + border_thickness, y + border_thickness, width - (2 * border_thickness), height - (2 * border_thickness), c)
    # Borders
    Gosu.draw_rect(x, y, width, border_thickness, border_color)
    Gosu.draw_rect(x, y, border_thickness, height, border_color)
    Gosu.draw_rect(x, y + height - border_thickness, width, border_thickness, border_color)
    Gosu.draw_rect(x + width - border_thickness, y, border_thickness, height, border_color)
  end
end
