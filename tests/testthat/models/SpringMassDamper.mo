model SpringMassDamper
  "Spring-mass-damper oscillator system"

  parameter Real m = 1.0 "Mass (kg)";
  parameter Real k = 100.0 "Spring stiffness (N/m)";
  parameter Real c = 1.0 "Damping coefficient (N.s/m)";
  parameter Real F0 = 10.0 "Initial force (N)";
  parameter Real x0 = 0.0 "Initial displacement (m)";
  parameter Real v0 = 0.0 "Initial velocity (m/s)";

  Real x(start=x0) "Displacement (m)";
  Real v(start=v0) "Velocity (m/s)";
  Real F "Applied force (N)";

  output Real x_max "Maximum displacement (m)";
  output Real settling_time "Settling time (s)";
  output Real overshoot "Overshoot (%)";

protected
  Real x_steady;
  Boolean settled(start=false);

equation
  // Force applied at t=0, then released
  F = if time < 0.01 then F0 else 0;

  // Equations of motion
  m * der(v) = F - k * x - c * v;
  der(x) = v;

  // Steady state displacement (for overshoot calculation)
  x_steady = 0.0;

  // Track maximum displacement
  x_max = max(abs(x), pre(x_max));

  // Overshoot calculation
  overshoot = if x_steady > 0 then
    (x_max - x_steady) / x_steady * 100 else 0;

  // Settling time (2% criterion)
  when abs(x) < 0.02 * x_max and not settled then
    settled = true;
    settling_time = time;
  end when;

initial equation
  x = x0;
  v = v0;
  x_max = 0;
  settling_time = 0;

end SpringMassDamper;
