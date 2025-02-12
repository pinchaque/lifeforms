# Returns the area of intersection between two circles given their x, y
# coordinates and radii. This is derived from the answer provided here:
# https://math.stackexchange.com/questions/3543367/area-of-overlap-of-two-circles
def circle_area_intersect(x0, y0, r0, x1, y1, r1)
  # distance between centers
  dx = x1 - x0
  dy = y1 - y0
  d = Math.sqrt(dy * dy + dx * dx)

  # if the circles aren't overlapping
  return 0.0 if d > (r0 + r1)

  rr0 = r0 * r0
  rrrr0 = rr0 * rr0
  rr1 = r1 * r1
  rrrr1 = rr1 * rr1

  # if one circle is contained within the other then the overlap is the
  # smaller circle
  return (Math::PI * rr0) if r1 >= (d + r0)
  return (Math::PI * rr1) if r0 >= (d + r1)

  dd = d * d
  dddd = dd * dd
  z = (2.0 * dd * rr0) + (2 * dd * rr1) + (2 * rr0 * rr1) - dddd - rrrr0 - rrrr1
  h = Math.sqrt(z) / (2.0 * d)
  alpha = Math.asin(h / r0)
  beta = Math.asin(h / r1)

  hh = h * h
  sa = (alpha * rr0) - (h * Math.sqrt(rr0 - hh))
  sb = (beta * rr1) - (h * Math.sqrt(rr1 - hh))
  sa + sb
end