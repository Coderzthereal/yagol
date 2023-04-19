require "yaml"
require "minitest/autorun"
require_relative "_window_helper" # To have method call reporting from game.window


class GameOfLifeTest < Minitest::Test
  def setup
    @test_opts = YAML.load_file("test/test_cfg.yml")
    @game = GameOfLife.new(**@test_opts)
  end

  def test_initialize
    assert_equal @game.all_tiles, (0...10).to_a.product((0...10).to_a)
  end
end
