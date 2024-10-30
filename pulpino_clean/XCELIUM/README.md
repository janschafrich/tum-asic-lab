# Simulation using Cadence Xcelium

> **Note**
> For the Xcelium simulator command `xrun` to be known, the `cadence_setup` has to be sourced.

## Font issues with SimVision
The wavewindow font on CentOS and Ubuntu is (depending on the screen resolution) small and hard to read.
This can be changed by copying the Xdefaults file from scripts to `~/.simvision/`.
Furthermore one needs to change the height of the waveforms from 10pt to 12pt in the preferences menu of simvision.
(Edit->Preferences->Waveform Window->Display->Waveform Height)

