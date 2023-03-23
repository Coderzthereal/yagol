# Copyright (c) 2023, Paul Hartman
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.
require_relative "update_handler"

module ButtonHandler
  def self.included(base)
    base.class_eval { include UpdateHandler }

    base.send(:alias_method, :_old_init_with_bitmask_from_include_ButtonHandler, :initialize_with_bitmask)
    base.define_method(:initialize_with_bitmask) do |*args, **kwargs, &block|
      _old_init_with_bitmask_from_include_ButtonHandler(*args, **kwargs, &block)

      @button_press_handlers = {}
      @button_down_handlers = {}

      # Implements button down handlers
      add_update_step(:button_down_handlers) do |window|
        @button_down_handlers.each do |keys, handler|
          if keys.any? { Gosu.button_down? _1 }
            handler[window]
          end
        end
      end
    end
  end

  # Implements button pushed handlers
  def button_down(id)
    handled = false
    @button_press_handlers.each do |buttons, handler|
      if [buttons].flatten.member?(id)
        handler[id]
        handled = true
      end
    end
    super unless handled
  end

  # Assigns a block to run when a button or set of buttons is pressed.
  # RUNS ONCE PER BUTTON PRESS. To run when a button is currently
  #  pressed down, use #define_button_down_handler.
  # For example:
  #    define_button_press_handler(Gosu::KB_ESCAPE) { close }
  def define_button_press_handler(*buttons, &handler) = (@button_press_handlers ||= {})[buttons.flatten] = handler

  # Assigns a block to run when a button or set of buttons is down.
  # RUNS EVERY TICK WHILE BUTTON IS PRESSED. To run once per button
  #  press, use #define_button_press_handler.
  # For example:
  #    define_button_down_handler(Gosu::KB_LEFT) { @camera_x -= 1 }
  def define_button_down_handler(*buttons, &handler) = (@button_down_handlers ||= {})[buttons.flatten] = handler
end
