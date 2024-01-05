Star Runner - BASIC 10Liner Contest 2023
====================================

Author:   Eric Carr
Language: FastBasic 4.6
Platform: Atari 8-bit
Category: EXTREM-256

Video: https://youtu.be/IkM_Cv0nQxM

Requirements:
System: Atari 8-bit w/ 48KB+ memory (800, xe, etc) w/ Joystick
Emulator: Atari800MacX (on Mac) or Altirra (Windows)


Game Story
===========
It is a time of war in your galaxy. Your people, the Atarians, defend against constant attacks from the  Commodorians. Due to circumstances beyond your control (a fixed lottery), it has been decided that you, Rom Antic, must deliver vital details to a secret base hidden deep in a safe part of your galaxy.

You hop into your aging ship, the Pokey Cruiser, and take off with no time to spare.

Unfortunately, the shortest path to the base is blocked by 10 waves of deadly asteroids and mines.

Your rather BASIC laser can only dispatch the smallest asteroids, so you will need to rely heavily on evasive maneuvers to dodge your way through all 10 waves and safely reach your goal.

Good luck! Atarians in the galaxy are counting on you!


Starting the game
===============
1. If using an emulator, set to Atari 130XE and enable keyboard joystick. 
2. Start the game by doing one of the following:
  A. Boot StarRunner.ATR disk, type "SR" and press [Enter]
  B. Drag/drop the StarRunner.XEX file directly on the emulator 
3. Press joystick button to start


How to Play
============
1. Use the joystick to move your ship LEFT and RIGHT
2. Press the button to FIRE
3. You have THREE chances to make it through all 10 waves, restarting at your last completed wave.


Listing the Source
==================
To LIST the source:
1. Boot StarRunner.ATR disk
2. Type "FB" and press [Enter]
3. It will load the FastBasic IDE and show the listing


Compiling the Source
====================
1. StarRunner-source.BAS is in Atascii format so it will look strange if you 
   view it on PC/Mac outside of a hex editor.
2. You can compile it directly to XEX using the FastBasic cross compiler
   on PC/Mac (e.g. "fastbasic StarRunner-source.BAS").


Background
==========
After not getting fine scrolling to work for Jumpman, I had some ideas for a space shooter and, after testing a parallel star scrolling idea, this developed into a simple asteroid dodger game. I wanted to showcase fine scrolling and more advanced background music in BASIC, running full speed on PAL and near full speed on NTSC.


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