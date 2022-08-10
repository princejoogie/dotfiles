local status, colorizer = pcall(require, "colorizer")
if (not status) then return end

colorizer.setup(
  {"*"},
  {
    rgb_fn = true,
    hsl_fn = true,
    RRGGBBAA = true,
    names = false
  }
)
