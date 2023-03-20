' Star Runner - BASIC 10Liner Contest 2023
' ========================================
' 
' Author  : Eric Carr
' Language: FastBasic 4.6
' Platform: Atari 8-bit (tested on 130XE)
' Category: EXTREM-256
'
' Unminified source code with comments
' h/i/j/k vars are for local/temp use
' All _vars are renamed when minified
' Handy Atari PMG Reference: https://www.atariarchives.org/pmgraphics/appendix.php
' 
' Tools Used
' ==========
' - FastBasic 4.6 Cross Compiler - Compile BASIC to XEX
'   https://github.com/dmsc/fastbasic/releases/tag/v4.6
' - Visual Studio Code - Editing the file
'   https://code.visualstudio.com/download
' - Atari FontMaker - Defining chars as block sprites
'   http://matosimi.websupport.sk/atari/atari-fontmaker/
' - SprEd - Player Missle Graphics Sprite editor
'   https://bocianu.gitlab.io/spred
' - Atari800MacX and Altirra

' Preinitialize _lives so it can be accessed in splash screen
_lives=0

' FUNCTION() - Splash Screen for Start and End of game
PR.s

' Set graphics mode to BASIC 17 (1+16) for the splash screen, and so print #6 will works with the custom display list
g.17 

' Set narrow playfield since it is vertical game, and lets us use more instructions per frame
poke 559, 33

' Position the text of the splash screen
POS.9,6

' Pause for vertical sync to avoid momentary text jitter caused by switching ti narrow playfield change
pause
if _lives
  ?#6,"you saved the",," GALAXY!"
  pause 60
else
  ?#6,"Star Runner",,,,"press FIRE"
e.

' Wait for joystick button press, while slowly playing background music after first play
W.P.644:@m:pause 2:WE.

' Clear all variables for easy memory leak prevention
clr

' Initialize Player Missle Graphics
pmg.2

' Set overlap mode for 3 color pmg, missles own color
P.623,49 

' Initialize arrays and vars
di._starDim(208),_stickDir(128),_missleY(1),_missleX(1),_soundNote(1)
_lives=3:_noteBeat=0

' Align our offscreen buffer at a 4K boundary for DisplayList
' Setting high enough to avoid other BASIC variables in my code.
_playfield=$4020

' Initialize playfield indexes and missle vars
_playfieldBuf = _playfield+500:_playfieldScrollDest=_playfield+32
_waitForMissle=0:_currentWave=0:_nextMissle=0

' Set index for pokey sound
_sound=$D200

' Sound effect arrays for missles/collisions
da._soundEnd()=110,0:da._soundStep()=5,0

' Index to Music Note Data (first 64 chars LEAD, second 64 BASS)
_musicI=1+&""$40$55$48$4C$60$00$6C$00$55$55$00$00$00$40$48$55$55$00$00$00$00$00$60$55$51$51$00$48$00$48$40$55$55$00$00$00$00$40$39$55$55$00$00$00$00$6C$60$6C$40$00$00$60$00$00$55$00$51$51$00$48$00$00$44$00$FF$FF$D9$D9$E6$E6$C1$C1$FF$FF$D9$D9$E6$E6$C1$C1$FF$FF$D9$D9$E6$E6$C1$C1$C1$C1$A2$C1$E6$E6$C1$C1$FF$FF$D9$D9$E6$E6$C1$C1$FF$FF$D9$D9$E6$E6$C1$C1$FF$FF$D9$D9$E6$E6$C1$C1$C1$C1$A2$C1$F3$F3$D9$D9

' Music End marker
_musicE=_musicI+64

' Lookups for start of memory PMG location to animate thrusters
_pm2=pm.2+111

  ' Set custom character set at 1024 byte aligned location 
_charset=$4800

' Custom Display List to enable offscreen buffer and vertical scrolling
i=$4400 ' Align at 1024K boundary
move &""$70$46$46$46$06$65$20$40$25$25$25$25$25$25$25$25$25$A5$25$05$41$00$44,i-1,39

dpoke i+2,dpeek(d.560+4) ' Top status rows uses existing memory buffer so print #6 works
dpoke 560,i ' Acivate the display list

' Clear colors to avoid color change flicker at start
mset 704,9,0

' Playfield and PMG Sprites
q=&""$00$10$00$41$00$04$40$00$C0$33$0E$3B$3F$0F$33$C0$03$CC$F0$FC$DC$70$CC$03$03$0B$2F$2D$BF$FF$3F$0F$40$D0$F4$F4$FF$FF$7D$F4$00$00$02$2F$2F$BF$F7$3F$00$B0$F4$FD$7D$FD$F4$40$00$00$02$2F$BD$BE$2F$0B$00$02$FF$FF$FF$7F$FF$FF$00$F4$FD$9D$FD$FD$F4$40$00$00$2C$BF$FF$3F$0D$00$2D$BF$BF$FF$FD$34$00$00$08$18$18$1C$9C$9C$F8$F9$F8$D8$1C$1C$00$10$18$18$38$39$39$1F$9F$1F$1B$28$28$30$04$04$08$0C$04$0C$08$08$20$20$10$00$20$00$10$10

' Each wave index is a set of possible wave parts (may differ slightly from my notes below)
' Waves
' 1 - small asteroids                     ' 2 - mostly small, with medium
' 3 - small, med, one brown               ' 4 - all brown med, spaced
' 5 - mostly small, medium, two per row   ' 6 - all brown med+large
' 7 - mines 2 per row, spaced 3           ' 8 - mixed, two per row
' 9 - brown all, 1 per row, every row     ' 10 - mines, 3 per row, spaced 4
' Frequency - $18=1, $0C=2, $08=3
' Wave Starts       1              2                 3                    4              5                       6                 7           8                          9                             10
_waveIndex=1+&""$02$03$18$01$03$03$02$18$01$03$05$04$02$18$01$03$05$16$02$03$18$13$16$05$02$0C$01$03$03$05$08$03$02$18$13$16$19$01$03$0C$1D$06$03$0C$01$03$0F$11$0B$19$07$01$18$05$08$0F$11$16$0B$19$01$04$08$1D

' Counter used to slow scroll dim star
_dimStarCounter=95

' Set player ship graphics
f.i=0t.1:m.q+97+13*i,pm.i+98,13:n.

  ' Copy ROM characters to custom character from to get letters/numbers
M.P.756*256,_charset,1024

' Create star chars and clear adjacent set of chars used for dim slow moving star effect
mset _charset,112,0
poke _charset+103,16
poke _charset+107,32

' Add sprite characters at 75+
move q,_charset+631,128

' Enable custom character set
P.756,72 ' 72 = $4800/256

' Each wave part is a list of [Char Len], [Char 1]..[Char N]
' Part HEX value key (gray, brown)
' 1|3, 0F|11 = Small Asteroids
' 5|8, 13|16 = Med Asteroids
' 0B, 19     = Large asteroid
' 1D         = Mine
'                   1     3     5        8        0B          0F    11    13       16       19          1D
_wavePart=&""$01$59$01$5A$02$52$53$02$54$55$03$56$57$58$01$D9$01$DA$02$D2$D3$02$D4$D5$03$D6$D7$D8$02$50$51

' Player missle thruster lookup (performance opt)
_pm3=pm.3+111

' Setup slow moving dim stars in a psuedo random fashion
for i=2 to 13
  h=h/2+96-i*2:_starDim(i)=h mod 12+1
  for j=1 to 13
    _starDim(i+j*16)=(_starDim(i)+j-1) mod 12 + 1
  next
next

' Initialize state.
_pmm = pm.-1:_pmStep=_pmm+6
@i

ENDP.

' Call the splash function to start the game
@s

' FUNCTION() - Initialize state for each new life
PR.i

' Clear onscreen missles
mset _pmm,128,0

' Is it game over and we should start over?
if n._lives :@s:exit: e.

' Draw all dim star rows onscreen to show stars on start
move &_starDim,_playfield,416

' Reset player position - Center position happens to be a palindromic number!
' _playerX is a WORD, two bytes that control the X position of PMG player 0 and 1. Instead of poking N to two locations, 
' I DPOKE N+256*N to one location. _playerX = N+256*N, and I adjust it by (1+256*1) 257 when moving a pixel to the left or right.
_playerX = 32123
_D000=$D000
dpoke _D000, _playerX
dpoke _D000+2, _playerX

' Lives go down by one
dec _lives

' Initialize Sound and set initial volume for missle sound effects
so.1,0,10,6
d._sound,$A400

' Show status bar
pos.2,0:?#6,c.128"ships   wave    ";c.128_lives

' Player & Playfield Colors.
m.&""$D8$E4$42$38$92$9f$06$26,703,9

' Joystick direction lookup, for speed. Checks if left or right is pressed, and multiplies direction (1 or -1) * 257 to move the player left or right a pixel.
for i=0 to 13
  _stickDir(i)=((n.i&8)-n.i&4)*257
n.

' Clear missle related arrays
mset &_missleY,12,0

' Reset wave timer and scrolling state
_waveTimer=12+_currentWave&1*98
_vscroll=2:_lastBrightX=0:_dimStarRow=11

' Clear PMG collisions
poke _D000+30,1
ENDP.


' =============================================================
' ======================== MAIN LOOP ==========================
' =============================================================
do  

  ' Read joystick direction to move player left/right
  _playerX=_playerX+_stickDir(p.632)

  ' Keep player within horizontal screen bounds
  if _playerX=$504E :_playerX=$514F:elif _playerX=$AAA8:_playerX=$A9A7:e.

   ' Can we fire a missle?
  if not _waitForMissle
    ' Check if joystick button is being pressed
    if not peek 644
      
      ' Reset missle wait counter
      _waitForMissle=17

      ' Determine X position of missle using mod 256
      i=_playerX&255+4
      
      ' Set Missle X position
      poke $D004+_nextMissle, i

      ' Render Missle on screen
      mset _pmm+92,6,3+9*_nextMissle

      ' Set missle X/Y values
      _missleX(_nextMissle) = i
      _missleY(_nextMissle) = 92
      
      ' Toggle next missle (up to 2 can be active)
      _nextMissle=not _nextMissle

      ' Initiate "pew pew" sound
      _soundNote(0)=85
    e.
  else
    dec _waitForMissle
  e.
  
  ' Two DECs takes 25% less cycles than _vscroll=_vscroll-2
  DEC _vscroll:DEC _vscroll

  ' Fine scrolled to the end, now we must increment entire row (coarse scroll)
  if _vscroll<0
    _vscroll=14
    
    ' Precalc dim star row location before vertical retrace
    i = &_starDim+32*_dimStarRow
    
    ' Reset dim star row if reached end 
    if not _dimStarRow 
      _dimStarRow=12
    e.
    
    ' Copy playfield to buffer (to avoid copying while drawing the screen, which caused flicker near the top)
    -move _playfield,_playfieldBuf,382

    ' Wait for vertical retrace
    pause
    
    ' Reset fine scroll 
    poke $d405,14

    ' Copy playfield back one row
    ' I first copy to a buffer, so that I can copy bytes top down to avoid vsync flicker
    ' I originally had a single move that copied bottom up, but by the time it reached
    ' the top, flicker would show to that part being drawn on the next jiffy
    move _playfieldBuf,_playfieldScrollDest,382

    ' Set player ship horizontal position
    dpoke _D000, _playerX

    ' Clear top row/add dim star
    move i,_playfield,28

    ' If an active wave, add foreground objects (asteroids, mines)
    ' Size optimization tip: &N-1 is a faster MOD N (works for power of two MOD2/4/8/16)
    if _currentWave&1 ' MOD 2
      ' Add an object for this row per mod timer
      if not _waveTimer mod p.(_waveIndex+1)

        ' Determine how many objects per row we can add via the step
        ' Objects 24/h. So, 24 = one object, 12 = two objects, 8=3
        ' I randomly place an object within each step's range
        h=p.(_waveIndex+2)

        ' Loop and add objects to this row
        for k=4 to 27 step h
          ' Get random object from list of available
          i = p.(_waveIndex+3 + rand p._waveIndex)
          ' Get the width of this object in characters
          j = p.(_wavePart+i)
          ' Render onscreen at random location within bounds
          move _wavePart+i+1, _playfield+rand(h-j+1)+k, j
        next
      e.
    else
      ' In between waves - add bright star
      i=_playfield+rand 12*2+5

      ' Only show star if in new X location. Atari RAND  seems to 
      ' repeat the same value many times in a row, which looks bad for stars.
      ' Size optimization: A-B is one less char than A<>B
      if i-_lastBrightX t. poke i,13
      _lastBrightX=i
    e.

    dec _dimStarRow:dec _waveTimer
    
    ' Set next wave when time runs out for current wave
    if not _waveTimer
      _waveTimer=32
      
      ' If a non star wave, increment wave index for the next set of obstacles
      if _currentWave and not _currentWave&1
        _waveIndex=_waveIndex+p._waveIndex+3
        _waveTimer=110
      e.

      ' Store current wave
      h=1+_currentWave/2

      ' Increment wave counter
      inc _currentWave
      
      ' Update status bar with current wave
      pos.6,1:?#6,c.128h

      ' Check if player reached the final wave
      if _currentWave>21
        mset _sound,8,0
        _lives=9:@s
      e.
    endif

  else ' perform fine scrolling this jiffy

    ' Wait for vertical retrace
    pause

    ' Fine Scroll
    poke $d405,_vscroll

    ' Shift the dim star character up so it scrolls down slower than foreground objects
    if n._vscroll&3
      
      ' Move dim star charset data back by one pixel, creating the parallex scrolling effect
      move _charset+9,_charset+8,96

      ' If the dim star pixel reached the last characters, reset to the starting character
      if n._dimStarCounter    
        poke _charset+103,16
        _dimStarCounter=96
      e.
      dec _dimStarCounter

      ' Animate the player ship's thrusters
      j = _dimStarCounter&3*2+q+123
      dpoke _pm2, dpeek j:dpoke _pm3, dpeek(j+8)
      @m
      
      ' Play missle and collision sounds
      for i=0 to 1
        if _soundNote(i)

          ' Adjust to new note using specified step
          _soundNote(i)=_soundNote(i)+_soundStep(i)

          ' Until it reaches the end note, which signifies to stop playing a sound
          i._soundNote(i)=_soundEnd(i) t. _soundNote(i)=0

          ' Instead of the Sound command, use poke which is faster
          p._sound+i+i,_soundNote(i)
        e.
      n.
    else

      ' Missle collision loop (up to two missles can be active)
      for j=0 to 1
        ' If missle in active
        if _missleY(j)>20
          
          ' Decrement missle Y position
          _missleY(j)=_missleY(j)-6
          
          ' Check if missle hit playfield
          if PEEK(_D000+j)>3
            ' Determine closest playfield character location
            i=_playfield+69+(_missleY(j)+_vscroll/2-16)/8*32+(_missleX(j)-81)/4
            
            ' Look for playfield chars near the missle
            for h=0 to 7
              k=peek i:if k>79 then exit
              i=h&1*-30+i-1
            n.

            ' Check if missle hit something that can be destroyed. The right most sprites can
            ' be shot (after 88). First, remove the 8th bit (inverse color) before
            ' checking using bitwise & (and), since the same asteroid can be rendered
            ' in normal and inverse color
            if k&127>88
              ' Replace asteroid with debree character
              poke i,79

              ' Initiate "shot asteroid" sound
              _soundNote(1)=230:_soundEnd(1)=130:_soundStep(1)=-25
              
            else ' Hit something that stops the missle and can't be destroyed
              ' Initiate "ping" sound
              _soundNote(1)=50:_soundStep(1)=5:_soundEnd(1)=60
            e.

            ' Remove missle from play
            mset _pmm+_missleY(j),12,0:_missleY(j)=0
          e.
        elif _missleY(j)
          ' If missle reached the top of screen, remove from play
          _missleY(j)=0:mset _pmm,34,0
        e.
      n.

      ' Reset any collisions
      poke _D000+30,1

      ' Move missle visually in step with the _missleY decrement
      move _pmStep,_pmm,104
    e.

    ' Set player ship (players 1 and 2) horizontal position
    ' Instead of two pokes of a byte, Double poke a word.
    ' PlayerX is N+N*256, and it is incremented by +/- 257 (1 + 256)
    ' which is the same as adjusting both bytes by +/- 1 
    dpoke _D000, _playerX
    ' Set player ship thruster (players 3 and 4) to match player position
    dpoke $D002, _playerX

    ' Check if player ship hit color 3 or 4 (colors 1/2 are used for stars)
    ' Instead of checking individually for PMG players 0 and 1 (bits 3&4 each, 4+8)
    ' DPEEK a word to boolean AND it against bits 3/4 in both at once (4+8+1024+2048=3084)
    if D.53252&3084
      ' Clear sound and create "uh oh" drone noise
      mset _sound,8,0:POKE _sound,24
      
      ' Volume up the engine sound
      for i=68 to 90:pause:mset 704,4,$32:POKE _sound+1,i/2:n.

      ' Explosion sound!
      for i=$72 to $ff step 12:mset 704,8,0:POKE _sound,i:pause 2:n.

      ' Clear sound, wait, then initialize for next life
      poke _sound+1,0
      pause 60
      @i
    e.
  e.

loop 

' FUNCTION() - Play backgroud music
pr.M
  
  ' Play new note
  if n._noteBeat 
    
    ' Play the bass note (dpoke to set both the note byte and the volume byte)
    dpoke _sound+4,p.(_musicI+64)+$A400

    ' Play the lead note, or decrease volume if 0 (fade away)
    IF p._musicI :_note=p._musicI:_vol=3: elif _vol: dec _vol: e.: dpoke _sound+6,_note+($a0+_vol)*256

    ' Increment/loop music note pointer
    inc _musicI:if _musicI=_musicE t. _musicI=_musicE-64

    ' There are 4 beats between each note
    _noteBeat=4
  else
    ' This executes between the notes
    dec _noteBeat

    ' Fade base note volume
    poke _sound+5,$a1+_noteBeat

    ' Add vibrato to lead note if it is fading away (lower than initial volume)
    if _vol<3 t. poke _sound+6,_note+_noteBeat-2
  e.

endp.
