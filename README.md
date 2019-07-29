# Pyloric Simulator
`puppeteer` doesn't fare well with very large numbers of synapses. These MATLAB 
scripts serve to allow easy simulation of the pyloric circuit without using a
graphical interface.

> The circuit diagram comes from [Nusbaum et al. 2017](https://www.nature.com/nrn/journal/v18/n7/abs/nrn.2017.56.html).

## Instructions
Usage is very simple. The scripts in the `network` folder produce `xolotl` objects which can be simulated normally (using `x.integrate` or `x.manipulate`).
In addition, they can be fed into `procrustes` pattern searches (via `inquisitor`) or `psychopomp` (via `whipporwhil`).