model Branin
  "Branin test function - common optimization benchmark"

  parameter Real x1 = 0.0 "First input variable";
  parameter Real x2 = 0.0 "Second input variable";

  output Real y "Branin function output";

protected
  constant Real a = 1.0;
  constant Real b = 5.1 / (4 * 3.14159^2);
  constant Real c = 5.0 / 3.14159;
  constant Real r = 6.0;
  constant Real s = 10.0;
  constant Real t = 1.0 / (8 * 3.14159);

equation
  y = a * (x2 - b * x1^2 + c * x1 - r)^2 + s * (1 - t) * cos(x1) + s;

end Branin;
