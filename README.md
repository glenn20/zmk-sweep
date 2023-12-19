
# My Ferris Zmk Layout

![sweep-layout](./images/BaseKeymap.svg)

## Layout

### Acknowledgements

- Influenced by
  [Miryoku](https://github.com/manna-harbour/miryoku/tree/master/docs/reference)
  layout but evolved through my own experience and biases
- Layer taps and mod taps customised following [@urob's timeless homerow
  mods](https://github.com/urob/zmk-config#timeless-homerow-mods)
- lots of browsing other user's zmk configs and the excellent zmk docs

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

#### BASE layer

Use qwerty layout with tweaks:

- Put `DEL` key on middle right for convenience (in place of `;`)
  - `DEL` is also provided on `NAV`, `NUM` and `FUN` layers
- Put `ESC` key on bottom right for convenience (in place of `/`)
  - `ESC` is also duplicated to `NAV`, `NUM` and `FUN` layers
- Shift-comma generates &caps_word to capitalise a word

#### SYM layer

- Dedicated `SYM` layer - with a layout that makes sense to me
  - all symbols can be accessed from this one layer without additional
    modifiers
  - symbols from the shifted number keys on a conventional keyboard along the
    top row
  - symbols stacked in logical pairs across middle and bottom rows
  - parenthesis/bracket/brace pairs all on left hand

#### NAV layer

- `NAV` layer key and main `NAV` keys on left side:
  - `LEFT-WORD`, `PGUP`, `PGDN`, `RIGHT-WORD`, `HOME`.
  - `LEFT`, `UP`, `DOWN`, `RIGHT`, `END`
  - `UNDO`, `CUT`, `COPY`, `PASTE`, `REDO`
- Easy to use with mouse on right hand
- Experimented with a lot of layouts for navigation keys
  - initially on right side but works better on left (I am a lefty)
  - initially used arrow keys in *inverted-T* on SDFC keys
    - liked this, but its more flexible to have all arrows on same row
  - arrow keys on home row which provide logical pairs with top row keys
- Right hand includes `DEL`, `DEL-WORD` and `BSPC-WORD`

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

- `SHIFT` on right thumb key hold
- Standard home-row modifiers (`SHIFT`, `CTRL`, `ALT`, `GUI`) on `ALPHA` and
  `SYM` layers
  - Using [@urob's timeless homerow
    mods](https://github.com/urob/zmk-config#timeless-homerow-mods)
- Dedicated home-row modifiers (`SHIFT`, `CTRL`, `ALT`, `GUI`) on right hand for
  `NAV`, `NUM` and `FUN` layers
  - like Miryoku layers

## Complete layout

![sweep-layout](./images/Keymap.drawio.svg)
