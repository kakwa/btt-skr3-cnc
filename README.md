# btt-skr3-cnc

Reviving a Yetitool CNC using a Bigtreetech SKR3 EZ + grblHAL + PI + gSender.

## Project Status

* [x] Pi configuration
* [x] Base GRBLHAL setup
* [ ] End Stops and safety stop configuration
* [ ] Spindle Control (optional)
* [ ] Proper Case for elec
* [ ] Wiring/adapter board 

## Hardware Configuration

- **Board**: [BTT SKR 3 EZ (STM32H7xx)](https://github.com/bigtreetech/SKR-3)
- **Stepper Drivers**: TMC5160
- **Control**: [BTT Pi](https://github.com/bigtreetech/BTT-Pi) running [gSender](https://sienci.com/gsender/)
- **Motors**: X, Y, Z + ganged X2, Y2
