## TickerTape Version 1.0 (September 2024)

### Programmers' Guide

***Ticker Tape*** relies on two rules files to decode the packets to and from the server. This document explains how these rules files are constructed.

- /Data/RulesIn.lua
    - Definition of packets **TO** the client
###
- /Data/RulesOut.lua
    - Definition of packets **FROM** the client

These files can be edited (in an editor of your choice) to add new packets to the decode list, or to correct mistakes I may have made. In its simplest form, a packet rule is a lua table containing a sequence of nested tables of instructions that are executed in turn, using the index to control the display order ... 
### 
![PG-001](PG-001.png)
###
## Overview
###
The rule is indexed as shown below, and while you can use decimal or hex I would recommend using the hex ID for the packet. Remember, there are many instances of a packet with the same ID being used (with different meaning) in both directions, so make sure you are working with the right packet, **in** or **out** ...
### 
![PG-002](PG-002.png)
###
Each line of the rule (each table) is executed in turn, from top to bottom (there are control sequence commands that are covered later). Each rule is organised such that the most important information, elements that are always present, are at the left of the table. This allows you to ignore elements at the end of the table that are not always needed. A FULL line is shown below ...
### 
![PG-003](PG-003.png)
###
This may look overwhelming, but going back to the original example ...
### 
![PG-004](PG-004.png)
###
This is used to display the line below ...
### 
![PG-005](PG-005.png)
###
The first table is empty (we have no special flow control commands), the second table just contains the byte offset in the packet (0). We only want to access a single byte which is shown as a raw value (raw values are always displayed in hex, {inside square brackets}, and decimal, {inside round brackets}) so we don't need a **decode** section. Finally the caption, **Packet ID** tells the user what is being shown. A very high percentage of data content can be displayed as simply as this. There are exceptions, and they can be extremely complex.

It is important that you make sure the line index is ...
- In order
- Has no duplicates

This is a limitation of the way lua indexes tables, if you have two lines with the same index one of them will be ignored. If you have them in the wrong order they will be executed out of order.

Anything in quotes (you can use single or double) is case sensitive. **ALL** commands are in lower case.

The rest of this guide explains how to construct the instruction lines needed to decode a packet. There is a lot of information in this guide, so this table of links has been provided for quicker future access.
###
|Section|Detail|
|:---:|:---|
|[Data Offset](#data-offset)|How to identify the data in the packet we want to use|
|[Data Decode](#data-decode)|How the data is interpreted|
|[Info](#info-1)|Additional text display|
|[Flow Control](#flow-control)|Loops, Calls etc|
|[Data Flags](#data-flags)|Complex flow control|
##
## Data Offset
### 
![PG-003-01](PG-003-01.png)
###
In most cases, such as in the original example, the offset into the packet is a single number, this can be expressed as decimal or hex.

If more than 1 byte is used, the bytes value is used to identify how many bytes are to be read from the packet at the offset location.

There are cases where the entire byte or value is not used, in which case the start bit is identified (this has a start index of 0) and the number of bits to use will be the last variable. If the number of bits is not supplied it is implied by the number of bytes requested, i.e. 3 bytes would result in 24 bits being used.
### 
![PG-006](PG-006.png)
###
The packet size above is a perfect example. The first bit of the second byte is not part of the size, so we read 7 bits starting at bit 1. Using packet x15 as an example, the first two bytes are ...

-   x15
-   x10

or

-   0001 0101
-   0001 0000

We take the byte at offset 1, ignore the first, or bottom bit, leaving us with the value 8.
### 
![PG-050](PG-050.png)
###
As you can see from the output, the value is further processed (the packet sizes are multipled by 4) and this is handled by the **decode** section.

FFXI reads bits sequentially from the packet in reverse bit order, i.e. in the example above, the second byte would be read as ...

-   0 : **0** : **0** : **0** : **1** : **0** : **0** : **0**

The first bit is part of the previous piece of data (the packet ID) so it reads the next 7 bits where the bit value is calculated from the index into the data. In some cases the client will memory move a block of data from the packet. When that occurs the data will have been put into the packet in the required order. You need to be aware of which unpack strategy the client is using for a given packet.
##
## Data Decode
### 
![PG-003-02](PG-003-02.png)
###
While it is often enough to look at the raw value from the packet, sometimes it is helpful to see a decoded, or at least partially decoded interpretation of the data. The data **decode** section is a table and can contain up to 4 of the following strategies. When no **decode** table is provided the code assumes the **'raw'** strategy is to be used. Remember to put the strings in braces, if this is not a table it will not be executed. In many cases you can follow the link for an example ...
###
|Type|Purpose|
|:---:|:---|
|[time](#)|A Timestamp (h,m,s)|
|[mstime](#)|A Timestamp (h,m,s ms)|
|[xyz](#xyz)|A location in +/- X, Y, Z|
|[dir](#dir)|A direction as an angle and text|
|[psize](#psize)|Display the corrected packet size|
|[eid](#eid)|An entity by its local ID/index|
|[entity](#entity)|An entity by its full ID|
|raw|The data as hex and decimal|
|[string](#string)|A display string|
|[music](#)||
|[weather](#)||
|[zone](#)||
|[house](#)||
|[bitflag](#bitflag)|A series of bits shown as 1 or 0|
|[ip](#ip)|An IP address|
|[store](#store)|A storage location from its ID|
|[item](#item)|An item name from its ID|
|[exdata](#)||
|[ability](#)||
|[info](#)||
|[vdate](#)|A date in Vana'Diel|
|[jpoint](#jpoint)|The description of an ability by its Job Point ID|
|[merit](#merit)|The name of a merit by its ID|
|[geo](#)||
|[job](#job)|A job / sub job based on ID|
|[bluspell](#bluspell)|A BLU spell based on its encoded short ID|
|[attach](#attach)|An automation attachment name based on its Sub ID|
|[puppet](#)||
|[status](#)||
|[spell](#)||
|[action](#)|An action performed by a player or NPC|
|[wskill](#)||
|[craft](#craft)|A craft based on its ID|

##
#### Examples ...
###

### bitflag
A **bitflag** type is often used when there are multiple consecutive bits in a byte, each with their own meaning.
### 
![PG-012](PG-012.png)
###
This sequence from the packet decode for an NPC update (packet IN 0x00E) contains 8 bit flags that identify which additional data in the packet is valid ...
### 
![PG-013](PG-013.png)
###
The eight (8) bits are shown in order and are grey if not tested. If a bit is tested and it is set it is shown in green, if it is tested and it is not set then it is shown in red.
###

### merit
A **merit** type converts an ID into a textual description of that merit ...
### 
![PG-014](PG-014.png)
###
Merit IDs are decoded from an external table. A merit will always be contained in a rword (2 byte) type.

### jpoint
A **jpoint** type converts an ID into a textual description of a job point and decodes its current state ...
### 
![PG-015](PG-015.png)
###
Job Points are decoded from an external table and will always be contained in a rword (2 byte) type.

Job point IDs do NOT follow the same order that they are listed by the cient and so often appear "out of order" in the packet. The **Lv** or level shows how many points have been spent on that ability, **Next** shows how much the next upgrade will cost. If Next is 0 then the ability is fully upgraded.

### xyz
An **xyz** type takes the values in 12 consecutive bytes and converts them into 3 floating point numbers that represent X, Y and Z coordinates ...
### 
![PG-016](PG-016.png)
###
This is one instance where the stated data source format is ignored, I don't know the correct name for a triple reverse dword.

### item
An **item** type takes the values from the packet and looks up the item with that ID ...
### 
![PG-017](PG-017.png)
###
The information is extracted by making a call to the Ashita core.

### store
A **store** type typically takes a single byte and converts it into a storage location ...
### 
![PG-018](PG-018.png)
###
The location is converted using an external lookup table.

### ip
An **ip** type takes four consective bytes and converts it into an IP address ...
### 
![PG-019](PG-019.png)
###
The address is commonly used by packets that are sent and received during the process of zone changing. It is commonly seen with the port address which is shown as a raw value ...
### 
![PG-020](PG-020.png)
###

### entity
An **entity** can be an NPC, or monster or even a pet. Its ID occupies a (four byte) rdword and this strategy converts this ID into a name ...
### 
![PG-021](PG-021.png)
###
NPCs are allocated a band of 4096 entries per zone, so the ID equates to the zone x 4096 plus an index in the range 0 ~ 4095. For reasons best known to SE you often see both in the same packet, even though the index could easily be extracted directly from the ID.

The name of the entity (if available) is found by calling the Ashita core.

### eid
An **eid** takes an "index in zone" and tries to find the ID of the entity ...
### 
![PG-022](PG-022.png)
###
This is not always possible, if it is, the name is shown, otherwise the ID is shown (as in the example above). If the **eid** yields a valid index it is identified via a call to the Ashita core.

### job
A **job** entry is always a single byte that is decoded into text ...
### 
![PG-023](PG-023.png)
###
A job and sub job are usually in the same packet and use the same decode. The job text is decoded from a local lookup table.

### dir
A **dir** entry is always a single byte that is decoded into the direction that a given entity is facing ...
### 
![PG-024](PG-024.png)
###
The direction is given as text and an angle. FFXI uses a system where 0 degrees is East and the angle is calculated clockwise.

### craft
A **craft** entry decodes the craft skill type as text and extracts the current rank and level as numbers ...
### 
![PG-025](PG-025.png)
###

### string
A **string** entry takes a plain text string from the packet and displays it ...
### 
![PG-026](PG-026.png)
###
It's not clear why the client needs these strings, it doesn't display them and they are often truncated to save space.

### info
It is often useful to put a reminder in the packet definition that informs the user of an important aspect of the data ...
### 
![PG-028](PG-028.png)
###
In this example the user is informed that any value >= 0x8000 are capped ...
### 
![PG-027](PG-027.png)
###
When the data offset is -1 it is NOT shown, this provides a visual break in the list.

### bluspell
Some packets contain job specific information and BLU is no exception. When the job related packets are in BLU mode they save space by compressing the spell IDs (they reduce all spells by 0x200). In this mode the spell is unpacked and its name obtained from the Ashita Core ...
### 
![PG-030](PG-030.png)
###

### attach
Some packets contain job specific information and PUP is no exception. When the job related packets are in PUP mode they save space by compressing the attachment IDs (they reduce all items by 0x2100 and store the compressed Sub Item ID). In this mode the attachment is unpacked and its name obtained from a lookup table (Sub Items are not currently available from the Ashita Core) ...
### 
![PG-031](PG-031.png)
###
The unpacked Sub ID is also shows so that it can be looked up (if you have access to the table in the SQL database).

### psize
The **psize** is unusual in that the packet size reported in the packet is wrong. Originally there were less than 256 packet IDs, meaning that the packet ID and the packet size could occupy two consecutive bytes. One day SE added a packet with an ID that would no longer fit in a byte and their solution was to steal the bottom bit from the packet size. As long as all packets were an even size (byte size divisible by 2) then the bottom bit could be removed, and the result shifted (essentially a multiplication by 4) to give the correct packet size ...
### 
![PG-050](PG-050.png)
###
##
## Info
### 
![PG-003-07](PG-003-07.png)
###
The **info** data is text that is shown at the end of a line, usually when bits are being decoded or to make an important point ...
### 
![PG-013](PG-027.png)
###
In this example **Values >= 0x8000 Are Capped** is the **extra** data.

##
## Flow Control
### 
There are several Flow Control commands that can be used to simplify the decode rules. Flow control commands are in the first table ...
### 
![PG-003-08](PG-003-08.png)
### 
These are explained in this section. For fast access you can follow the link below ...
###
|command|Purpose|
|:---:|:---|
|[if / ifnot](#if--ifnot)|Execute (or not) a single line|
|[call](#call)|Call another rule (as a sub routine)|
|[loop](#loop)|Repeat a list of rules a given number of times|
|[switch](#switch)|Execute one of several blocks of rules|
##
### if / ifnot
###
This is the simplest of the flow control commands. It allows you to ignore a rule based on the values in the packet ...
### 
![PG-042](PG-042.png)
###
This line, from the PUP decode section of a packet, will list up to 12 attachments, it is performed in a loop, which is covered a bit lower down. If the slot is empty I don't want to decode it and a) waste space, b) confuse the viewer.

The **ifnot** will check the value at byte 10 (the **offset**) and if it is not 0 (the check value in the command) the line will run, otherwise the code steps on to the next line.

Not surprisingly, the **if** works the opposite way, the line will run ONLY if the value in the packet matches the check value.

You can add a second parameter, if the test fails, instead of stepping forwards by 1 line it will step forwards the number of lines specified, allowing you to step over undesirable lines.
##
### call
###
This is the equivalent of a function call. I have used this where packet patterns repeat, such as wih the header ...
### 
![PG-043](PG-043.png)
###
Because there are no packets with IDs above **0xF00** I set function calls from **0xFFF** backwards.

The **0x00A** packet calls the **0xFFF** to decode the 4 bytes of the header, then returns to line 2 to continue decoding. This can save you a lot of time.

You must always include a **return** command at the end of the function or processing will stop.
##
### loop
###
A loop has a start **loop** command and an **end** command as shown below ...
### 
![PG-044](PG-044.png)
###
The value at **A** is the number of times the loop (the instructions between the **loop** and the **end**) will repeat, in this case a single line, line 6. The value at **B** is added to the byte offset of each line every time the end is reached. In this instance line 6 will be processed 10 times with an offset of 8, 12, 16, 20 etc.

If **B** is set to -1 then the size of the target object is used, so in this example it would be 4 (bytes), but if it was accessing a word (2 bytes) the increment would be 2 etc.

The value at **C** is a BIT offset that can be added when you want to "walk down" a word, etc. In that instance you would probably set **B** to 0.

At this time it is **NOT** advisable to nest loops. This will be fixed in a future version.
##
### switch
###
The switch command works in similar manner to C in that it allows you to execute a single block of lines and provides a default for when a match is not found ...
### 
![PG-045](PG-045.png)
###
Packet 0x044 is a good example because it has 2 job specific sections (BLU/16 and PUP/18) and a catch all, the default, for all the other jobs.

The switch statement identifies the byte to check, and the size of the data, i.e. 1 = byte, 2 = word etc ...
### 
![PG-046](PG-046.png)
###
In this instance we are looking at a single byte at packet offset 4. This is quite common and byte 4 is often used as a **mode** byte.

The code next walks down the lines looking for **case** commands, specifically one that matches the byte extracted.

If a match is found, all lines after the **case** are executed until the matching **break** is found. Once the **break** is found the code will look for the matching **end** statement, in this instance on line 99.

If a match is NOT found and a **default** is encountered, the code will execute everything between the **default** and the matching **break**.

As you can see, it is both allowed and common to run a **loop** inside a **case** block. At this time you cannot nest switch statements, maybe next version.
##

## Data Flags
### 
![PG-003-05](PG-003-05.png)
###
There are quite a few occasions where a bit flag is set in a packet that affects the validity of data later in the packet. This option allows you to set a flag based on data in the packet and later use this flag to change the way data is shown ...
### 
![PG-036](PG-036.png)
###
In this example you will notice in the top four lines each one sets a different flag based on a bit position. These are shown as follows ...
### 
![PG-037](PG-037.png)
###
Any bit that is set is shown in green, those that are not are shown in red.

Later in the packet there are position data fields that are validated by the flag on line 6 (see large box enclosed in red, lines 10 ~ 14). If the flag specified (we **use** 1) the data is shown as normal ...
### 
![PG-038](PG-038.png)
###
On line 8 we set a flag (flag 3) for the validity of the HP and status. As this flag was not set the bit display showed it in red.

When the data associated with this flag is shown (lined 16 & 17) the colour reflects the fact that the flag was not set ...
### 
![PG-039](PG-039.png)
###
The data is still visible, but it is (hopefully) obvious that it is not valid.
##

### Tables
### 
There are quite a few cases where the data is not available directly from the Ashita core, but is well known and organized into a convenient list. In these instances we make use of an external lists to decode the data.
### 

The tables currently available are as follows ...

|Table Name|Contents|
|:---:|:---|
|TAB_Actions|Names of actions|
|TAB_Storage|Names of storage locations|
|TAB_Attach|Names of puppet attachments (by sub ID)|
|TAB_Merits|Names of merits|
|TAB_JPoints|Names of Job Point effects|
|TAB_Music|Names of songs|
|TAB_Weather|Names of weather formats|
|TAB_MogHouse|Names of mog house locations|
|TAB_ActCats|Names of action categories|
|TAB_WSkills|Names of weapon skills|
|TAB_Abilities|Names of Abilities|
|TAB_Mounts|Names of Mounts|
|TAB_Recasts|Names of Ability Recasts|
|TAB_LogStates|Names of Zone log states|
|TAB_Geo|Names of GEO colure effects|
|TAB_Puppet|Names of Puppet parts|

##

---
### D'Hoffryn
Sept 2024