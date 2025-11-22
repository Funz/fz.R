model BouncingBall
  "Simple bouncing ball model with gravity and ground contact"

  parameter Real h0 = 1.0 "Initial height (m)";
  parameter Real v0 = 0.0 "Initial velocity (m/s)";
  parameter Real e = 0.7 "Coefficient of restitution";
  parameter Real g = 9.81 "Gravity acceleration (m/s2)";

  Real h(start=h0) "Height above ground (m)";
  Real v(start=v0) "Vertical velocity (m/s)";

  output Real h_max "Maximum bounce height (m)";
  output Real t_ground "Time to first ground contact (s)";
  output Integer bounces "Number of bounces";

equation
  der(h) = v;
  der(v) = -g;

  when h <= 0 then
    reinit(v, -e * pre(v));
    bounces = pre(bounces) + 1;
  end when;

  h_max = max(h, pre(h_max));

  when h <= 0 and pre(h) > 0 then
    t_ground = time;
  end when;

initial equation
  h = h0;
  v = v0;
  bounces = 0;
  h_max = h0;
  t_ground = 0;

end BouncingBall;
