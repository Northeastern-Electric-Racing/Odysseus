This is the code for Newracom/HaLow setup for Odysseus 22A.  Full details can be found in the NER Confluence.

This setup process is tested for:
- [NRC sw v1.4.1](https://github.com/newracom/nrc7292_sw_pkg) (+ [NRC RPi setup instructions v1.5](https://github.com/newracom/nrc7292_sw_pkg/blob/master/package/doc/UG-7292-018-Raspberry_Pi_setup.pdf))
- [NRC SDK v1.5.2](https://github.com/newracom/nrc7292_sdk)
- OS: Raspberry Pi Lite 64 bit (Bookworm).
- Hardware: [ALFA AHPI7292S PiHAT](https://docs.alfa.com.tw/Product/AHPI7292S/30_Technical_Details/) (the board data file is different, and in terms of these setup scripts is otherwise interchangable with a NRC EVK)



## Current Bugs
- On AP mode, the leds will not run until a device is initially connected to the AP Pi's ethernet.

More Info: If no ethernet device makes a handshake with br0, the process start.py never exits, which tells systemd to not change from activating to activated.  Thankfully though the oneshot unit type does not kill start.py because of this, but it does hold up the boot process and could cause issues with items that await targets past multi-user.  One possible fix is by implementing a notify system similar to STA mode, but such a process is undesirable.


