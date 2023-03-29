require "yaml"
require_relative "../src/game_of_life"

# Stub (turn into mock)
WindowClass, GameOfLife::Window = GameOfLife::Window, Class.new # To redefine entire class instead of adding to it
class GameOfLife::Window
  attr_reader :called
  def initialize(**kwargs)
    @called = {}
    @window = WindowClass.new(**kwargs)
  end

  def method_missing(...) = @called[store(...)] = @window.send(...)

  def respond_to_missing?(...) = @window.respond_to?(...)

  private def store(first_arg = nil, *args, **kwargs, &block) = [
    first_arg, args, kwargs, block
  ]
end

opts = YAML.load_file("../cfg/main.yml")
game = GameOfLife.new(**opts)

# Just to see what we're working with
game.show
puts
pp game.window.called
