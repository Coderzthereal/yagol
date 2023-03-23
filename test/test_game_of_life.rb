require "yaml"
require_relative "../src/game_of_life"

# Stub (turn into mock)
GameOfLife::Window = Class.new # To redefine entire class instead of adding to it
class GameOfLife::Window
  attr_reader :called
  def initialize(**kwargs) = @called = {}

  def method_missing(method, *args, **kwargs, &block) = @called[method] = [args, kwargs, block]

  def respond_to_missing?(...) = true
end

opts = YAML.load_file("../cfg/main.yml")
game = GameOfLife.new(**opts)

# Just to see what we're working with
begin
  game.show
  pp game.window.called
rescue Exception => e
  pp game.window.called
  raise e
end
