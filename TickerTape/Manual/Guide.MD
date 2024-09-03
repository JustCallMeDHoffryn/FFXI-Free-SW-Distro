## TickerTape Version 1.0 (September 2024)

### Introduction

***Ticker Tape*** is a packet capture addon for Ashita v4, it is used to capture and view packets sent between a FFXI Server and the Client program. The addon will show you the last 36 (thirty-six) packets as a real-time updating list, or ticker tape. You can pause the list at any time and select individual packets to view in detail.

Ticker Tape can also be used to save packets to file for offline analysis, this is independent of the real-time packet viewing.

Packet decoding is accomplished via a pair of files containing decode rule. At the time of writing this manual a significant number of packets still need to be decoded. Ticker Tape was written to fill my need to see packets in real time, so I am adding new packet definitions as I need them. This is an ongoing process and new definitions will continue to be added over time. 

Because Ticker Tape relies on community information the bit patterns may or may not be 100% accurate for any given server, it has, however, been tested on the August 2024 LSB server.
##
### Installation

To install the addon make a copy of everything here, including the /DATA folder. It would be a good idea to copy the /MANUAL folder for future reference.

If you want to auto-load the addon you will need to add it to the ***default.txt*** script. I do, however, recommend loading the addon manually once the game client has loaded. This allows the addon to load/save settings between runs. This is a known bug that I will fix at some point. 
##
### First Run

When you start Ticker Tape you will see the ***Sequencer*** window ...
### 
![TT-001](TT-001.png)
###
If the window does not appear you can use the command line ...

```/tt show```

This is a toggle and can be used to show / hide the windows at any time without interfering with the operation of the packet capture.

You will see the packets streaming from the top of the window to the bottom, and then scrolling with the newest packet at the bottom of the window. While in ***run mode*** the window background is almost transparent minimizing the amount of the game information being obscured, while still showing the packet sequence.
### 
![TT-002](TT-002.png)
###
Each line has four (4) pieces of information, **A)** The time (min:sec) of the packet arrival, **B)** The ID (in Hex) of the packet, **C)** The direction of travel (this example is from the client to the Server) and finally **D)** The type of packet.

The example below shows a packet travelling from the Server to the Client. The Blue / Green colour coding is a standard for FFXI packets ...
### 
![TT-003](TT-003.png)
###
If you want to view a packet click on the Run button at the top left of the window, alternatively you can use the command ...

```/tt run```

to toggle **Run Mode** on / off.

When Run Mode is off the Packet Viewer window is opened, this is initially empty. To view a packet select the packet name (the yellow part) in the Sequence list ...
### 
![TT-004](TT-004.png)
###
You can change the displayed packet at any time by selecting a different packet in the Sequencer list, or by means of the **Previous** "<<" and **Next** ">>" buttons at the top right of the Packet Viewer window.

You will see that the Packet Viewer is split into two sections with the top of the window showing the raw hex data and the bottom part showing the decoded data in the packet.

If you don't want to see the hex, maybe it takes up too much space, or isn't helpful, you can disable it by clicking the **Raw** button at the top left of the Packet Viewer window.

This is especially useful in complex packets that would otherwise scroll ...
### 
![TT-005](TT-005.png)
###
You will notice a tab at the bottom right of the Packet Viewer ...
### 
![TT-005a](TT-005a.png)
###
This allows the window to be resized as needed.
##
### Filter

Some packets are sent quite frequently and, as long as you are not interested in them, can clutter the Sequencer list. Fortunately there is a way to hide these unwanted packets. Click on the **Config** button, at the top right of the Sequence window. 

A new window will open listing all of the packets, in two tables, Out and In ...
### 
![TT-007](TT-007.png)
###
You can deselect any packet in these lists and the packet will no longer appear in the Sequencer.
### 
![TT-008](TT-008.png)
###

**NOTE ...** 

- The addon will remember your settings between runs (You should manually load the addon to make use of this feature).
###
- A packet that is disabled in this way will still be saved as part of a packet capture (see below).

##
### Capture

To capture data for offline analysis click the **Save** button at the top of the Sequence window. The name of the file will be shown in the top section of the window ...
### 
![TT-006](TT-006.png)
###
**NOTE ...** 

- The addon does not need to be in Run Mode for it to capture packets to disk, this function is independent of all other features.
###
- The addon will save files in the **/captures** folder, which it will make for you if it doesn't already exist.
###
- Packets that have been disabled in the Sequencer will still be saved by this process.
###
- You can start / stop the packet capture using the ```/tt save``` toggle.
##
### Questions

**Q:** Why Ashita v4 and not Windower?
**A:** There are good quality packet capture addons for Windower and I have no desire to duplicate anyone elses work.
###
**Q:** Why Ashita v4 and not v3?
**A:** If you are using Ashita you should move to v4. I know it is still classed as a Beta but it is significantly more advanced as a platform than v3. Just upgrade and be done with it.
###
**Q:** Why does it show "**No Rules**" in the Packet Viewer window?
**A:** I have released the code because it is in a usable state (not to say there are no bugs, there probably are). The addon has two tables of "rules" that are used to decode the packets. The packet you are looking at is not in either list (I am still adding them).


You have two options ...

- You can edit the rule table yourself, the [Programmers Guide](Prog.MD) will help you.
- You can send me a message and I will try to add the missing rule for you.
##
##
***D'Hoffryn***
2024

