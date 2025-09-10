
# My Ferris Zmk Layout

![sweep-layout](./images/BaseKeymap.drawio.svg)

## Layout

### Acknowledgements

- Influenced by
  [Miryoku](https://github.com/manna-harbour/miryoku/tree/master/docs/reference)
  layout but evolved through my own experience and biases
- Layer taps and mod taps customised following [@urob's timeless homerow
  mods](https://github.com/urob/zmk-config#timeless-homerow-mods)
- lots of browsing other user's zmk configs and the excellent zmk docs
- Relevant personal usage considerations:
  - Left handed but use mouse on right hand

#### Thumb keys

- Keypress:
  - `ENTER` and `TAB` on left thumb keys
  - `SPACE` and `BSPC` on right thumb keys
    - my muscle memory was right thumb for space bar
- While held:
  - `SYM` (blue) and `NAV` (red) layers on left thumbs (`SETTINGS` layer on
    combo)
  - `SHIFT` and `NUM` (green) layer on right thumbs (`FUN` layer on combo)
    - `SHIFT+ENTER` will generate `ESC` key
    - `SHIFT+BSPC` will generate `DEL` key
- `TAB`, `ENTER`, `SPACE`, `BSPC` are on hold-taps, so won't repeat when held:
  - Repeating (non-modifier) versions of each key are on other layers
    - so `SYM`|`NAV`->`SPACE`|`BSPC` and `NUM`->`TAB`|`ENTER` will produce
      repeating keys when held.
  - Also use `quick-tap-ms=225` for repeat on fast click then hold
- To lock the `NUM` layer:
  - Hold both left thumb keys (`ENTER`+`TAB`) and press `NUM` key on the
    right thumb :
    - Return to `BASE` layer with `TAB`+`BSPC` combo (both outer thumb keys)
- To lock the `NAV` layer:
  - Hold both right thumb keys (`SPACE`+`BSPC`) and press `NAV` key on the
    left thumb:
    - Return to `BASE` layer with `TAB`+`BSPC` combo (both outer thumb keys)

#### BASE layer

- Use qwerty layout (includes `; , . /` keys)

  - `q w e r t` --- `y u i o p`
  - `a s d f g` --- `h j k l ;`
  - `z x c v b` --- `n m , . /`
    - `TAB ENTER` - `SPC BSPC`

#### SYM layer

- Put all symbol keys on a single layer - with a layout that makes sense to me
  - ``! @ # $ %`` --- `^ & * ( )`
  - `` ` < ? ' ;`` --- `| - + [ ]`
  - ``~ < ! " :`` --- `\ _ = { }`
    - `TAB ENTER` - `SPC BSPC`
  - all symbols can be accessed from this one layer without additional modifier
    - except `.`, `,` and `/` - which are on the `BASE` layer
  - symbols from the shifted number keys on a qwerty keyboard along the top row

#### NAV layer

- `NAV` layer key on left and main `NAV` keys on right side:
  - `WORD   BSPC-WORD   BSPC    DEL    DEL-WORD`
  - `LEFT     DOWN       UP    RIGHT    HOME`
  - `LWORD    PGDN      PGUP   RWORD    END`
- Experimented with a lot of layouts for navigation keys
- Right hand top row includes `DEL`, `DEL-WORD` and `BSPC-WORD`
- Left hand side:
  - `ESC` is on `NAV-Q`.
  - `caps-word` is on `NAV-G`

#### NUM layer

- Num-pad like arrangement on left hand
  - `/ 7 8 9 -` --- `WORD BSPC-WORD BSPC  DEL  DEL-WORD`
  - `* 4 5 6 +` --- `----   SFT     CTL   ALT    GUI`
  - `0 1 2 3 .` --- `SPC     _       ,     .     ESC`
    - `TAB ENTER` - `SPC BSPC`
  - includes `*`, `/`, `+`, `-` keys
- Right side includes `_` and `,` for typing numbers
- Lock the `NUM` layer by holding both left thumb keys (`NAV+SYM`) and pressing `NUM`

#### FUN layer (Function keys)

- `F1-F9` function keys on number key locations
- `F10-F12` on left little finger column.
  - `f12 f7 f8 f9  PRINT` --- `SLEEP  VOL-  MUTE  VOL+  POWER`
  - `f11 f4 f5 f6 INSERT` --- `----   SFT   CTL   ALT   GUI`
  - `f10 f1 f2 f3  -----` --- `----   ---   ---   ---   ---`
    - `NAV BASE` - `SPC BSPC`
- includes media volume and pc power control keys on right side

#### SETTINGS layer

- includes **bluetooth**, **reset**, **reflash** and **output** control on left
  hand
  - `USB BLE bt4 --- BTCLR` --- `----- Left-CLK Mid-CLK Right-CLK  ESC`
  - `GUI ALT CTL SFT RESET` --- `RESET  M-LEFT    M-UP    M-RIGHT  SCRL-UP`
  - `bt0 bt1 bt2 bt3 FLASH` --- `FLASH   BACK    M-DOWN   FORWD    SCRL-DN`
    - `--- ---` - `BASE NUM`
  - Bluetooth profile numbers on corresponding number layer keys
- Mouse navigation keys on right hand (and **reset**, **reflash**):
  - top row: mouse button clicks
  - middle row: move mouse up/down/left/right

#### Modifiers

- `SHIFT` on right inner thumb key hold
- Standard home-row modifiers (`SHIFT`, `CTRL`, `ALT`, `GUI`) on `BASE` and
  `SYM` layers
  - Using [@urob's timeless homerow
    mods](https://github.com/urob/zmk-config#timeless-homerow-mods)
- Dedicated home-row modifiers (`SHIFT`, `CTRL`, `ALT`, `GUI`) on right hand for
  `NAV`, `NUM` and `FUN` layers
  - like Miryoku layers

## Complete layout

![sweep-layout](./images/Keymap.drawio.svg)
