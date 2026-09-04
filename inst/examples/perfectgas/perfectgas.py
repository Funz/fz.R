#!/usr/bin/env python3
"""A stand-in "external simulator" for the ideal gas law.

It is deliberately tiny but behaves like a real solver driven by fz:
it reads the compiled input deck ``perfectgas.txt`` from the current
working directory (fz runs each case in its own directory), solves

    P = n R T / V

and writes the result to ``out.txt``. fz then extracts ``pressure``
from that file via the model's ``output`` command.

Run standalone with:  python3 perfectgas.py
"""
import re

R = 8.314462618  # gas constant, J / (mol K)

deck = open("perfectgas.txt").read()


def value(name):
    """Read `name = <number>` from the input deck."""
    match = re.search(rf"{name}\s*=\s*([-\d.eE+]+)", deck)
    if match is None:
        raise SystemExit(f"missing '{name}' in perfectgas.txt")
    return float(match.group(1))


T = value("temperature")
V = value("volume")
n = value("moles")

P = n * R * T / V

with open("out.txt", "w") as out:
    out.write(f"pressure = {P:.6f}\n")
