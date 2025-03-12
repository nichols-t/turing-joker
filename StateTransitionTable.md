# State Transition Table


This table describes the state transitions that the Turing Joker uses.
Each state corresponds to a Joker position (numerical); Joker positions
above 13 are applied modulo 13. 

Each row represents the Symbol on the tape. These symbols correspond to
card ranks and the blank symbol (which represents writing a new card).

| Symbol |   1   |   2   |   3   |   4   |   5   |   6   |   7   |   8   |   9   |  10   |  11   |  12   |  13   |
| ------ | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
|      A |W+S,M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|
|      2 |    M_L|W+S,M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|
|      3 |    M_R|    M_R|W+S,M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|
|      4 |    M_L|    M_L|    M_L|W+S,M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|
|      5 |    M_R|    M_R|    M_R|    M_R|W+S,M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|
|      6 |    M_L|    M_L|    M_L|    M_L|    M_L|W+S,M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|
|      7 |    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|W+S,M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|
|      8 |    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|W+S,M_L|    M_L|    M_L|    M_L|    M_L|    M_L|
|      9 |    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|W+S,M_R|    M_R|    M_R|    M_R|    M_R|
|      T |    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|W+S,M_L|    M_L|    M_L|    M_L|
|      J |    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|W+S,M_R|    M_R|    M_R|
|      Q |    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|    M_L|W+S,M_L|    M_L|
|      K |    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|    M_R|W+S,M_R|
|      B |W+A,M_R|W+K,M_R|W+Q,M_L|W+J,M_R|W+T,M_L|W+9,M_R|W+8,M_L|W+7,M_R|W+6,M_L|W+5,M_R|W+4,M_L|W+3,M_R|W+2,M_L|
|      S |   T   |   T   |   T   |   T   |   T   |   T   |   T   |   T   |   T   |   T   |   T   |   T   |   T   |

## Symbols

The symbol at a tape position is the rank of the card at that position in the hand.
`B` represents a blank tape space (i.e. no card at that index) and `S` represents stone cards.

## Instructions

Each instruction cell contains a `W+` followed by a rank to write, as well as `M_` where `_` is
`L` or `R`. This denotes which direction to move the head.

State transitions are applied as the rank of the current symbol modulo the number of Jokers. For
example, if the player has 4 Jokers, is in state 3, and a `2` is read from the hand, the next state
will be 1 = 3 + 2 modulo 4.


### General Transition Rules
- State Movement:
  - The next state is the rank of the current symbol modulo the number of jokers
  - Terminate if the symbol is a stone card
  - Move **TODO** if the symbol is a blank card
- Head Movement:
  - Odd rank cards move the head **right**
  - Even rank cards move the head **left**
  - Blank cards move the head **TODO**
- Tape Writing:
  - If the current state has an **edition**, that edition is also written to the current tape position
  - Diagonals (i.e. state `i`, symbol `i`) write a stone card to the current position.