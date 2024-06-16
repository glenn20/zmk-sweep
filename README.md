
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
  - `SPACE` and `BSPC` on right thumb keys (my prior usage was right thumb for
    space bar)
- On hold:
  - `SYM` (blue) and `NAV` (red) layers on left thumbs (`SETTINGS` layer on
    combo)
  - `SHIFT` and `NUM` (green) layer on right thumbs (`FUN` layer on combo)
    - originally had `SYM` on right thumb with `SPACE`, but too complex when
      typing symbols surrounded by spaces (eg. code dev)
      - moved `SYM` to left and `NAV` to second left thumb key.
    - Chose to make right thumb key a shift key (I like this much better)
      - pushed the `FUN` layer onto a combo of right thumbs.
- `TAB`, `ENTER`, `SPACE`, `BSPC` are on hold-taps, so won't repeat when held:
  - Repeating (non-modifier) versions of each key are on other layers
    - so `SYM`|`NAV`->`SPACE`|`BSPC` and `NUM`->`TAB`|`ENTER` will produce
      repeating keys when held.
  - Also use `quick-tap-ms=175` for repeat on fast click then hold
- `ENTER`+`SPACE` is convenient shortcut to `ESC`

#### BASE layer

- Use qwerty layout (includes `; , . /` keys)

  - `q w e r t` --- `y u i o p`
  - `a s d f g` --- `h j k l ;`
  - `z x c v b` --- `n m , . /`
    - `TAB ENTER` - `SPC BSPC`

#### SYM layer

- Dedicated `SYM` layer - with a layout that makes sense to me
  - ``! @ # $ %`` --- `^ & * ? ESC`
  - `` ` ( ) [ ]`` --- `\ - = ' ;`
  - ``~ < > { }`` --- `| _ + " :`
- all symbols can be accessed from this one layer without additional modifiers
- symbols from the shifted number keys on a qwerty keyboard along the top row
  (except brackets)
- Left hand:
  - `` ` `` and `~` on the left and parenthesis/bracket/brace pairs
- Right hand:
  - `\ - = ' ;` on middle row with _shifted_ variants on bottom row `| _ + " :`
- `ESC` on inner right thumb key (`SPACE` key) and upper right key
  - To consider: remove ESC on inner thumb so we can have SPACE on SYM layer.

#### NAV layer

- `NAV` layer key and main `NAV` keys on left side:
  - `LEFT-WORD PGUP PGDN RIGHT-WORD HOME`
  - `LEFT UP DOWN RIGHT END`
  - `UNDO CUT COPY PASTE REDO`
- Easy to use with mouse on right hand
- Experimented with a lot of layouts for navigation keys
  - initially on right side but works better on left (I am a lefty)
  - initially used arrow keys in _inverted-T_ on SDFC keys
    - liked this, but its more flexible to have all arrows on same row
  - arrow keys on home row which provide logical pairs with top row keys
- Right hand includes `DEL`, `DEL-WORD` and `BSPC-WORD`
- Line movement keys on top right hand row: dedent, line-down, line-up, indent

#### NUM layer

- Num-pad like arrangement on left hand
  - includes `*`, `/`, `+`, `-` keys
- Right side includes `_` and `,` for typing numbers
  - `UNDO`, `CUT`, `COPY`, `PASTE`, `REDO` on top row and `BSPC`, `DEL` on inner
    column

#### FUN layer (Function keys)

- `F1-F9` function keys on number key locations
- `F10`, `F11` and `F12` are on left little finger column (from bottom to top).
- includes media volume and pc power control keys on right side

#### SETTINGS layer

- includes **bluetooth**, **reboot**, **reflash** and **output** control on left
  hand
- Desktop navigation keys on right hand (and **reboot**, **reflash**):
  - top row: `SHIFT`-`CTRL`-`ALT`-(`LEFT`, `DOWN`, `UP`, `RIGHT`): move window
    to desktop
  - middle row: `CTRL`-`ALT`-(`LEFT`, `DOWN`, `UP`, `RIGHT`): switch to desktop
  - bottom row: `GUI`-(`LEFT`, `DOWN`, `UP`, `RIGHT`): move window to side of
    desktop

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
