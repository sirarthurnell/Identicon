defmodule Identicon do
  @moduledoc """
  Generates an identicon.
  """

  @doc """
  Program's main entry.
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
  end

  @doc """
  Picks the color to use.
  """
  def pick_color(image) do
    %Identicon.Image{hex: [r, g, b | _tail]} = image

    [r, g, b]
  end

  @doc """
  Gets the bytes of the MD5
  representation of `input`.
  """
  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end
end
