Jumpman - BASIC 10Liner Contest 2023
====================================

Author:   Eric Carr
Language: FastBasic 4.6
Platform: Atari 8-bit (tested on 130XE NTSC)
Category: EXTREM-256

Video:    https://youtu.be/9hduoBHhvNM

Requirements:
System: Atari 8-bit w/ 48KB+ memory (800, xe, etc) w/ Joystick
Emulator: Atari800MacX (on Mac) or Altirra (Windows)

***
NTSC / PAL NOTE: This game was designed on NTSC. All SOURCE/LISTING/SCREENSHOT is
for the NTSC version, which is to be considered for the 10 Liner contest.

As an EXTRA, I did include PAL executables, which is nearly the same code with colors
that look better in a PAL emulator. The game runs much faster on PAL and so is
more challenging to play than the NTSC.
***


Starting the game
===============
1. If using an emulator, set to Atari 130XE and enable keyboard joystick.
2. Start the game by doing one of the following:
  A. Boot Jumpman.ATR disk, type "JM" or "JMPAL" and press [Enter]
  B. Drag/drop the Jumpman.XEX or Jumpman-PAL.XEX file directly on the emulator 
3. Press joystick button to start


How to play
===========
This is a randomly generated endless scroller where Jumpman runs
automatically and you control his jumping.

Go as far as you can to make the highest score!

Every 200 points, level changes and it gets harder!

1. Only the joystick button is used.
2. Press the button to jump. Hold the button to jump higher.
3. Jumpman runs automatically.
4. The game ends if you fall off the screen.


Listing the Source
==================
To LIST the source:
1. Boot Jumpman.ATR disk
2. Type "FB" and press [Enter]
3. It will load the FastBasic IDE and show the listing


Compiling the Source
====================
1. Jumpman-source.BAS is in Atascii format so it will look strange if you 
   view it on PC/Mac outside of a hex editor.
2. You can compile it directly to XEX using the FastBasic cross compiler
   on PC/Mac (e.g. "fastbasic Jumpman-source.BAS").


Background
==========
This is my first 10-liner entry and an homage to Mario (originally
known as Jumpman).  The melodies/sounds are based on Super Mario Bros.

Inspiration began when I was testing fine scrolling in Atari Basic and
decided to try a simple Mario Run style game. It quickly became too
slow for fine pixel scrolling, so I went with a 40x12 multicolor 
character mode that lets me scroll coarsely by 4 pixels (1 char width)
using FastBasic's move command to quickly move memory contents. This
replaces using strings to move memory in the built-in Atari BASIC.

I looked at world block sprites from Super Mario 1 (which
are 16x16 pixels) and made similar tiles by hand as 12x12
(rendered as 6 4x8 chars). This let me fit more blocks on the screen
horizontally, but the tall vertical height meant less chars to render
and scroll (better for speed).

For the Jumpman character, SprEd Library already had a Mario animation,
which was very helpful in understanding how the 3rd color works for Atari
PMG. I modified it slightly and added a jump frame.

Atari normally has space above and below the playfield, so to achieve
ground at the true bottom of the screen similar to Super Mario, I used
a Display List to add extra blank space between the top score rows and
the rest of the playfield.

FastBasic's IDE supports only 255 characters per line, so I used the
FastBasic cross compiler on my pc to compile a source file with 256
characters/line. The source file is still formatted for the Atari
platform (Atascii) and can be LISTed on the machine/emulator via TYPE
or in the FB IDE.

Part of the challenge would be getting the data (playfield, PMG sprites,
music, level setup) as small as possible to allow enough room for the game
logic and some sound. I experimented with hex, base64, dictionary and RLE
compression and finally settled on RLE in raw strings, replacing "new line"
and quotes with unused substitute characters. I also used a contiguous unused 
set of byte values so RLE could be done with 2 characters. For instance,
bytes 175-185 would support RLE runs of 3 to 13 chars. So, {175}{65} means
three {65} chars. {176}{65} means four {65} chars and so on. 

For the world generation, I settled on creating a few different "sections"
of blocks, and every 6 frames I randomly pick a new section to render
off-screen, which is then scrolled into view, at different Y locations.
Certain sections (anything but a pipe) can repeat a random duration.

I originally made custom 0-9 numbers, but that took too much extra space
so I ended up copying alpha/numeric from the atari rom and displaying on
the top two lines as a single color text mode using the Display List.

While the frame rate isn't as smooth as I'd like, I'm happy with the result
and learned some optimization lessons by taking up the 10 liner challenge.

This went through a repeated process of "It's as small as I can make it!" to
looking at it a day later and squeezing out 20 more characters and adding small
things. It originally had just a single set of colors and music. Aligning the
line endings as close to 256 chars meant shuffling things around every time
I made a change.

I've included the un-minified source code, with longer variable names and
comments to breaks down the logic and my thought process. It is be a mix
of full statements (IF..THEN..ELSE..END) and minified (I. T. EL. E.) but
have comments for nearly every line.


Tools Used
==========
- FastBasic 4.6 Cross Compiler - Compile BASIC to XEX
  https://github.com/dmsc/fastbasic/releases/tag/v4.6
- Visual Studio Code - Editing the file
  https://code.visualstudio.com/download
- Atari FontMaker - Defining chars as block sprites
  http://matosimi.websupport.sk/atari/atari-fontmaker/
- SprEd - Player Missle Graphics Sprite editor
  https://bocianu.gitlab.io/spred
- Atari800MacX and Altirra - Emulators