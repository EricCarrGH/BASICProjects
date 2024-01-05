' Jumpman - BASIC 10Liner Contest 2023
' ====================================
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

' RLE compressed data (playfield chars, PMG sprites, colors, block sections, and music)
' When minifying, each $XX byte is written out as an ATASCII char. I map quote and new lines to different chars so they don't cause issues (reconstituted during decompression).
da.q()b.=""$D5$26$7F$BF$56$24$FE$23$F9$D5$23$7E$EB$56$FE$FE$6B$56$7F$EA$D5$23$7F$F7$A7$E7$B6$56$26$FE$AB$D5$23$7E$D5$75$5D$25$57$23$55$25$FF$56$5A$6A$25$EA$57$5A$6A$AA$24$00$FF$23$AA$24$00$EA$BA$AE$AB$24$00$AA$BF$95$25$BD$AA$FF$26$7F$AA$FF$55$25$7F$AA$FF$57$FE$FF$FE$FF$FE$AA$FF$BA$EA$BA$EA$BA$EA$AA$FE$26$AE$BD$AA$0A$25$0B$7F$AA$AA$25$D7$7F$AA$AA$25$F7$FF$AA$AA$FE$FF$FE$FF$FE$BA$AA$AA$EA$AA$EA$AA$EA$A2$AA$A0$25$E0$28$0B$28$D7$28$F7$FF$FE$FF$FE$FF$FE$FF$FE$AA$EA$AA$EA$AA$EA$AA$EA$28$E0$2C$00$07$0F$01$0B$09$07$07$02$C3$E3$CF$1F$3F$1C$2A$00$07$0F$01$0B$09$07$07$00$00$18$3C$07$0F$0C$2B$00$07$0F$01$0B$09$07$07$01$01$03$01$13$0B$07$2A$00$07$0F$01$0B$09$07$07$02$C3$E3$4F$0F$07$0F$2B$00$0F$23$1F$07$3D$FC$EC$C1$00$00$60$70$38$2A$00$0F$23$1F$07,
da.b.=""$03$07$1F$3B$18$10$30$21$2C$00$0F$23$1F$07$0E$1E$1C$1E$0F$07$00$07$2B$00$0F$23$1F$07$3D$FC$EC$40$10$38$70$40$28$00$C0$F8$A0$B8$DC$80$F0$20$17$F3$F0$F8$F8$38$2A$00$C0$F8$A0$B8$DC$80$F0$C0$58$1C$18$F0$F0$E0$2B$00$C0$F8$A0$B8$DC$80$F0$00$80$23$E0$C0$2A$00$0E$CE$FE$A0$B0$DC$80$F0$20$10$F0$23$F8$80$2B$00$E0$F8$FC$F8$F0$C0$EF$0F$12$23$06$2C$00$E0$F8$FC$F8$F0$20$B8$FC$F8$23$00$C0$E0$2B$00$E0$F8$FC$F8$F0$C0$60$80$23$00$E0$80$28$00$0E$0E$06$EE$FE$FC$FC$F8$D0$E2$02$96$06$06$26$00$44$F8$44$F8$0C$00$36$D8$86$B8$D8$00$08$08$30$00$18$30$18$48$00$00$0D$1A$39$46$01$04$05$06$04$05$06$01$02$03$01$02$03$01$0A$0B$0C$0A$0B$0C$07$08$09$07$08$09$04$0A$0B$0C$0A$0B$0C$07$08$09$07$08$09$99$9A$19$9C$9D$9E$93$94$95$96$97$98$8D$8E$8F$90$91$92$01$23$1F$0A$0B$0C,
da.b.=""$23$1F$07$08$09$01$23$1F$04$05$06$23$1F$01$02$03$A2$00$00$D9$00$00$FF$FF$00$C1$00$AD$00$B6$C1$00$D9$80$00$6C$60$00$79$6C$00$80$00$A2$90$AD$00$00$D9$6C$FF$80$F3$79$2A$00$A2$51$C1$60$B6$5B$2A$00$23$F3$00$FF$00$CC$CC$D9$00$99$99$23$A2$00$23$AD$00$23$CC$AD$A2$CC$F3$F3$99$CC$FF$00$D9$80$00$80$00$90$00$90$00$A2$A2$00$6C$51

' Array variables. I put all of the vars that get initialized to zero at game start here, so
' I can clear them all with "mset &h,n,0" instead of doing h=0:_score=0:_yDelta=0 and so on
di._d(30),_f(999)b.,h,_score,_yDelta,_pn,_platY,_jumped,_jumpS,_c,_n,_musN

' Sound register pointer
_sound=$D202

' Code to decompress the RLE data in q() to _f().
' First I shift the two later strings to the left (m.i+245,i+244,247:m.i+493,i+491,107) to remove the 1st byte FastBasic uses to store string lengths, so it becomes one contiguous chunk of data in memory
' Secondly, I go through each character and check for RLE (i.k>33a.k<44:h=k-32)
' Lastly, I convert 17 to quote and 25 to line ending, and it all ends up in _f.
i=&q+1:m.i+245,i+244,247:m.i+493,i+491,107:f._c=8t.858:i.h:de.h:el.:k=p.i:i.k>34a.k<45:h=k-33:inci:k=p.i:e.:inci:e.:i.k=17t.k=34:i.k=25t.k=$9B:_f(_c)=k:n.

' Section start. A section defines a possible grouping of blocks to add to the map (like ground, a pipe, or floating platform)
' A section contains multiple rows of 2 blocks each. A block is 12x12 pixels. Each char is 4x8 pixels, so a block is made up of 3 chars wide by 2 chars tall (1.5 technically)
' Since a block consists of 3 chars, one row is 6 chars total.
_sec=&_f+666

' Player animation frame pointer
_af=_sec-12

' Start of music pointer
_music=&_f+748

' Playfield width. Normal 40 char width of screen plus 6 chars for offscreen buffer to draw to
_W=46

' Sector index pointer
_secI=660

' Function to initialize a new game.
PR.I
  ' Show Welcome / Game Over Screen
  g.17
  j=&"JumpMan"
  if _score
    j=&"game over"
    POS.6,10:?#6,"SCORE ";_SCORE
    f.i=97t.111:p._sound-2,p.(_music+i):pa.7:n.
  e.
  pos.6,5
  ?#6,c.128$(j)
  POS.1,19:?#6,"press FIRE to play"

  ' Wait for joystick button press
  W.P.644:WE.

 ' Re-dim Playfield to clear it
  di._playfield(900)

  ' Custom Display List to enable wider screen buffer and taller screen. I space out the first two rows (score) 
  ' and rest of the playfield to push the "ground" blocks to the bottom of the screen.
  i=&_D
  _n=&_playfield
  ms.i,12,$70
  ms.i+1,4,70
  d.i+2,_n
  d.i+5,_n+20
  i=i+13:F.j=0to11:p.i-1,$55:d.i,_n+_w:_n=_n+_w:i=i+3:n.
  P.i-1,61:D.i,&_d 
  
  ' SET Display List and clear colors to black during loading of sprites
  dpoke 560,&_d:ms.704,9,0

  ' Initialize player missle graphics
  PMG.2: P.623,49 ' Set overlap mode for 3 color pmg

  ' Start of playfield pointer
  _m=&_playfield+50

  ' Set initial values for game state
  _scoreX=_m-18:_ySubRow=7:_maxN=3:_si=1:_sl=2:_notDied=1:_musicI=1:_moved=1:_musicS=_music

  ' Set initial values
  _space=2:_yRow=_m+239 '_yRow=_m+_w*5+9

  ' Draw ground
  f.j=0t.45:h=_m+414+j:p.h,1+j m.3:p.h+_w,1+j m.3+3:n.

  ' Set character set to PMG-2048, so we know if will be 1024 byte aligned
  i=pm.4-2048
  
  ' Copy A-Z and 0-9 from rom to use for the top score row 
  M.P.756*256+128,i+192,340:-M.i+192,i+384,80
  
  ' Copy our custom character set
  M.&_f,i,256

  ' Clear the slash in 0 to use it as an O in "score"
  ms.i+387,2,102
  
  ' Enable the custom character set
  P.756,i/256

  'Draw pipes
  j=_m+372
  for i=0 to 2:MOVE _sec+_f(_secI+3)+13+i*6,j-_w*i,6:n.

  'Player frame pointer
  _pms=&_f+256

  ' Set initial player animation frame
  _s=3

  ' Set sound volume
  p._sound+1,164:p._sound-1,164


  
  ' Show "score" text on screen using system byte values instead of ATASCII
  m.&";+0:-"+1,_scoreX-25,5

  ' Reset vars to 0. Less code than a=0:b=0:c=0:d=0:e=0, etc. I dim them 
  ' all together so they are contiguous in memory
  mset &h,20,0

 ' Set initial player y and draw sprite
  _y=65:@a

  ' Set player X position (align the 4 player sprites, two making left side of player, two making right side of player)
  f.i=0t.3:pm.i,70+8*(i>1):n.
 
 ' Set colors for Player sprite and playfield 
  m._af-14,704,9
  
  ' Pause a bit before starting to run
  pause 40
endp.

' Initialize the game
@i

' Main loop
do
  ' Increment score every 30 frames of running (about once a second)
  if n._moved
    _moved=30
    _score=_score+10

    ' Convert score to a string, then poke to the screen
    i=&str$(_score):m.i+1,_scoreX-p.i,p.i
    
    ' When score passes 200, change colors/music/add more single blocks to increases difficulty and keep things changing
    if _score mod 200=0
      ' Increase the number of sectors available until we hit max
      if _maxN<5 t. inc _maxN
      ' Change the music start pointer
      _musN=(_musN+1) mod 3
      _musicS=_music+_musN*32
      ' Update colors
      m._af-8+_musN*3,710,3
    e.
  e.

  ' Process Joystick Button
  if n.p.644
    ' Player will continnue to jump up to 10 frames as long as button is pressed
    if _c<10
      ' If the first frame of jump, initialize the jump sound
      if n._jumped 
        _jumped=1
        _jumpS=93
      e.
      inc _c:_yDelta=-5:_s=5
    e.
  elif _c 
    _c=99
    ' If let go of button when jumping, set the delta to 0 so the player
    ' will start falling quicker. This gives a predictable "end jump early"
    ' behavior to the player
    if _yDelta<0 t. _ydelta=0

    ' =======================
    ' Function to animate the player (draw current vertical position/frame)
    ' This would normally go at the end of the code, but is placed here
    ' to assist with fitting everything within the 256 char 10 line limit.
    PR.A

      ' Pre-calc the frame source/player destination location to 
      ' have as little time between vertical blank and drawing as possible
      h=pm.0+_y
      j=p.(_af+_s)+_PMS

      ' If the player is too high, it will cause artifacts as
      ' some PMG players will loop and draw at the bottom of the screen.
      ' So we just draw from an empty section of the playfield array
      if _y<-8 t. j=_m+700

      ' Wait for vertical blank
      pause

      ' Move the 4 PMG players that make up our player to the new vertical
      ' position (_y)
      for i=h to h+384 step 128
        MOVE j,i,24:j=j+96
      n.
    ENDP.
    ' =======================
  e.

  ' Play jump sound
  if _jumpS
    _jumpS=_jumpS-4
    i._jumpS<54 t. _jumpS=0
    ' Instead of the Sound command, use poke which is faster
    p._sound-2,_jumpS
  e.

  ' Apply downward force (gravity!)
  if _yDelta<4 t. inc _yDelta
  
  ' Update player Y values
  _y=_y+_yDelta:_ySubRow=_ySubRow+_yDelta

  ' Detect when crossing into a new row, if player is low enough to hit
  ' the playfield
  if _y>20
    if _ySubRow<0
      ' Player rises to the next row
      _ySubRow=_ySubRow+8:_yRow=_yRow-_w
    elif _ySubRow>7
      if p.(_yRow+43) or p.(_yRow+45)
        ' Hit ground. Stop falling and allow jump to occur.
        _y=_y-_ySubRow+7:_c=0:_yDelta=0:_ySubRow=7:_jumped=0
      else
        ' Player continues to fall to the next row
        _ySubRow=_ySubRow-8:_yRow=_yRow+_w:_c=99:_si=1
      
        ' Player is at bottom of screen and fell to death!
        if _y>109 
          ' Play the "oh no!" sound
          f.j=75t.60s.-7:f.i=j t.j+7
            p._sound,i
            ' A short delay is needed. Since we need to clear the Player sprite,
            ' do it in the loop here which takes up just the right amount of time (how lucky!)
            ms.pm.0,512,0
          n.:n.
          p._sound,0
          pause 40:@i
        e.
      e.
    e.
  e.

  ' Animate the player (draw the latest frame), waits for vertical blank
  @a
  
  ' If not colliding with a block and not falling to player's death
  if n.p._yRow a. _notDied

      'scroll left a single char. Do this asap after the vertical blank in @a
      move _m+1,_m,505 

      ' Signal the player moved for the score counter    
      dec _moved   

      ' Every 6 frames, draw a new 3 block (6 char) wide section offscreen
      ' that will scroll into view. Some blank space is added
      ' between each section
      dec _sl
      if n._sl
        _sl=6:_o=_m+546

        ' Play background music every 6 frames as well
        ' Could have had an independent counter to make the
        ' music faster, but that adds size
        p._sound,p.(_musicS+_musicI)
        _musicI=_musicI m.32+1
        
        ' Are we done adding columns of blank space?
        dec _space
        if _space<1 

          ' Pick section type
          if n._n
            _n=r._maxN+1
              
            ' If randomly selected the same as previous, don't repeat, just pick ground.
            if _pn=_n t._n=1
            
            _secPointer=_sec+_f(_secI+_n)

            ' If not continuing previous or ground, pick new Y level
            if _n > 1 and _n < 5
              ' Pick a random Y location
              _platy=_platy+r.2*2+2
              ' If a pipe, reduce by 3 since it's taller than other sections
              ' This ensures the player can jump to it
              if _n=3
                _platy=_platy-3
                if _platy<0 t. _platy=0
              e.

              ' Wrap the section Y location if it goes to low or high
              h= p._secPointer
              if _platy<0 :_platy=-_platy: elif _platy>8-h:_platy=8-h:e.
            else
              ' This section is the ground, so set Y to 0
              _platy=0
            e.

            ' Set previous sectioN variable 
            _pn=_n
          e.

          ' Possibly extend section horizontally (to be repeated) if not a pipe  
          _space=r.3+2*(_n>2)
        
          ' Pre-fill empty space below section
          F._O=_O to _O-_w*_platy S.-_w:MSET _o,6,0:N.

          ' Draw section
          for i=_secPointer+1 to _secPointer+1+6*p._secPointer step 6:MOVE i,_o,6:_o=_o-_w:n.
        else
          ' Adding blank space, so reset section type to 0
          _n=0
        e.
      
        ' Post-fill empty space above section
        F.i=_m+40 to _O S._w:MSET i,6,0:N.
      e.

      ' Increment player frame for running animation
      if n._jumped!_c
        dec _si
        i.n._si
          _si=2
          _s=_s m.4+1
        e.
      e. 
  elif _yDelta>0
    ' If not moving horizontally and falling, the player has no hope and will fall to death.
    _notDied=0
  e.
L.

' Uncomment for quick debug printing of values
'PR.out h:i=&str$(h):m.i+1,&_playfield+19-p.i,p.i:ENDP.