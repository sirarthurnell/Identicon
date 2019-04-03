defmodule Identicon do
  @moduledoc """
  Generates an identicon.
  """

  @doc """
  Program's main entry.

  ## Example

    iex> Identicon.main("banana")

  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Saves the bitmap of the image to disk.
  """
  def save_image(bitmap, input) do
    File.write("#{input}.png", bitmap)
  end

  @doc """
  Draws the actual image.
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    bitmap = :egd.create(250, 250)
    fill = :egd.color(bitmap, color)

    Enum.each pixel_map, fn({top_left, bottom_right}) ->
      :egd.filledRectangle(bitmap, top_left, bottom_right, fill)
    end

    :egd.render(bitmap)
  end

  @doc """
  Builds the pixel map.
  """
  def build_pixel_map(image) do
    %Identicon.Image{grid: grid} = image

    pixel_map = Enum.map(grid, fn {_value, index} ->
      x = rem(index, 5) * 50
      y = div(index, 5) * 50

      top_left = {x, y}
      bottom_right = {x + 50, y + 50}

      {top_left, bottom_right}
    end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Filters the odd squares.
  """
  def filter_odd(image) do
    %Identicon.Image{grid: grid} = image

    grid =
      Enum.filter(grid, fn {value, _index} ->
        rem(value, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Builds the grid.
  """
  def build_grid(image) do
    grid =
      image.hex
      |> generate_chunks
      |> Enum.map(&mirror/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Generates the chunks.
  """
  def generate_chunks(list) do
    Enum.chunk_every(list, 3, 3, :discard)
  end

  @doc """
  Mirrors a list of three elements.
  """
  def mirror(row) do
    [a, b | _tail] = row

    row ++ [b, a]
  end

  @doc """
  Picks the color to use.
  """
  def pick_color(image) do
    %Identicon.Image{hex: [r, g, b | _tail]} = image

    %Identicon.Image{image | color: {r, g, b}}
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
