# Copyright (c) 2023, Paul Hartman
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.
module UpdateHandler
  # Update Gosu's world and the tick count. Runs 60 times per second.
  def update
    @tick_count ||= 0
    @tick_count += 1
    @update_steps.each { |name, step| step[self] }
  end

  # Adds a named block to run during the update sequence.
  def add_update_step(name, &step) = (@update_steps ||= {})[name] = step
end
