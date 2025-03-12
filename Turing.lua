SMODS.Atlas {
  key = "Turing",
  path = "turing.png",
  px = 71,
  py = 95
}

-- [card symbol][joker index] = 'rank to write'..'tape move direction'
turing_state_transitions = {
  ----------|  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12 |  13 | (joker state)
  --[[ A ]] { 'SR', 'AR', 'AR', 'AR', 'AR', 'AR', 'AR', 'AR', 'AR', 'AR', 'AR', 'AR', 'AR' },
  --[[ 2 ]] { '2L', 'SL', '2L', '2L', '2L', '2L', '2L', '2L', '2L', '2L', '2L', '2L', '2L' },
  --[[ 3 ]] { '3R', '3R', 'SR', '3R', '3R', '3R', '3R', '3R', '3R', '3R', '3R', '3R', '3R' },
  --[[ 4 ]] { '4L', '4L', '4L', 'SL', '4L', '4L', '4L', '4L', '4L', '4L', '4L', '4L', '4L' },
  --[[ 5 ]] { '5R', '5R', '5R', '5R', 'SR', '5R', '5R', '5R', '5R', '5R', '5R', '5R', '5R' },
  --[[ 6 ]] { '6L', '6L', '6L', '6L', '6L', 'SL', '6L', '6L', '6L', '6L', '6L', '6L', '6L' },
  --[[ 7 ]] { '7R', '7R', '7R', '7R', '7R', '7R', 'SR', '7R', '7R', '7R', '7R', '7R', '7R' },
  --[[ 8 ]] { '8L', '8L', '8L', '8L', '8L', '8L', '8L', 'SL', '8L', '8L', '8L', '8L', '8L' },
  --[[ 9 ]] { '9R', '9R', '9R', '9R', '9R', '9R', '9R', '9R', 'SR', '9R', '9R', '9R', '9R' },
  --[[ T ]] { 'TL', 'TL', 'TL', 'TL', 'TL', 'TL', 'TL', 'TL', 'TL', 'SL', 'TL', 'TL', 'TL' },
  --[[ J ]] { 'JR', 'JR', 'JR', 'JR', 'JR', 'JR', 'JR', 'JR', 'JR', 'JR', 'SR', 'JR', 'JR' },
  --[[ Q ]] { 'QL', 'QL', 'QL', 'QL', 'QL', 'QL', 'QL', 'QL', 'QL', 'QL', 'QL', 'SL', 'QL' },
  --[[ K ]] { 'KR', 'KR', 'KR', 'KR', 'KR', 'KR', 'KR', 'KR', 'KR', 'KR', 'KR', 'KR', 'SR' },
B=--[[ B ]] { 'AR', 'KR', 'QL', 'JR', 'TL', '9R', '8L', '7R', '6L', '5R', '4L', '3R', '2L' },
}


SMODS.Joker {
  key = "turingjoker",
  loc_txt = {
    name = "Turing",
    text = {
      "{C:attention}Reprograms{} played cards",
      "based on Joker editions."
    }
  },
  config = {
    delta = turing_state_transitions
  },
  rarity = 3,
  atlas = "Turing",
  pos = { x= 0, y = 0 },
  cost = 11,
  -- Scoring calculation
  calculate = function(self, card, context)
    if context.before then
      local state = 1 -- todo read from G.jokers.cards
      local tape_index = 1

      local iterations = 1
      
      while state ~= nil do
        sendInfoMessage('Number of Steps: '..iterations)
        sendInfoMessage('Current State: '..state)
        sendInfoMessage('Tape Index: '..tape_index)
        -- get current symbol and next state
        local current_symbol = nil
        local next_state = nil
        -- note this may be nil
        local current_card = nil
        -- tape_index in [, #G.hand.cards] means card is there, otherwise it's blank
        if tape_index > #G.hand.cards or tape_index < 1 then
          current_symbol = 'B'
          -- todo state transition from a blank symbol == increment state?
          next_state = (state  + 1) % #G.jokers.cards + 1;
        else
          current_card = G.hand.cards[tonumber(tape_index)]
          current_symbol = current_card:get_id()
          next_state = current_symbol % #G.jokers.cards + 1;
          -- terminate on a stone card
          if current_card.ability.effect == 'Stone Card' then
            next_state = nil
            break
          end
        end

        -- aces stored at 1 not 14
        if current_symbol == 14 then current_symbol = 1 end

        sendInfoMessage('Current Symbol: '..current_symbol)
        sendInfoMessage('Next State: '..next_state)

        -- given current symbol, read the write value and the tape direction
        local write_symbol = string.sub(turing_state_transitions[current_symbol][state], 1, 1)
        local tape_direction_string = string.sub(turing_state_transitions[current_symbol][state], 2)
        local tape_direction = 1
        if tape_direction_string == 'L' then
          tape_direction = -1
        end

        sendInfoMessage('Writing Symbol: '..write_symbol)
        sendInfoMessage('Current State: '..state)
        sendInfoMessage('Next State: '..next_state)
        
        -- store edition of current state as we'll need to write this to a card
        local current_state_edition = G.jokers.cards[state].edition
        -- ensure we have a "current card" on blank tape index by making a new one
        -- rank is the symbol we said we would write, and suit is random
        if current_card == nil then
          local new_card_suit = nil
          new_card_suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('turing'))
          current_card = create_playing_card(
            {
              front = G.P_CARDS[new_card_suit..'_'..write_symbol]
            },
            G.hand,
            nil,
            nil,
            {G.C.SET.Default}
          )
        end

        -- update variables for the next iteration
        state = next_state
        tape_index = tape_index + tape_direction
        iterations = iterations + 1

        -- add the edition to the existing/new card if needed
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 1,
          func = function()
            if current_state_edition ~= nil then
              current_card:juice_up()
              current_card:set_edition(current_state_edition, true, true)
            end
            return true
          end
        }))
        card_eval_status_text(current_card, 'extra', nil, nil, nil, {message = "Programmed!"})
      end
      
      playing_card_joker_effects({true})

      return {
        message = 'Program complete!'
      }
    end
  end
}
