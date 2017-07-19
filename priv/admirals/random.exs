defmodule RandomAdmiral do
  @behaviour AdmiralBehavior

  def team_name() do
    now = Time.utc_now
    {us, _} = now.microsecond

    "random-#{us}"
  end

  def initialize() do
    ships = Enum.shuffle([:aircraft_carrier, :battleship, :cruiser, :submarine, :destroyer])

    
  end
end
