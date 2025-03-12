SMODS.Atlas {
  key = "Turing",
  path = "turing.png",
  px = 71,
  py = 95
}

-- [card symbol][joker index] = 'rank to write'..'tape move direction'
turing_state_transitions = {
  ----------|  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12 |  13 | (joker state)
  --[[ A ]] { 'SR', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R' },
  --[[ 2 ]] { ' L', 'SL', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L' },
  --[[ 3 ]] { ' R', ' R', 'SR', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R' },
  --[[ 4 ]] { ' L', ' L', ' L', 'SL', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L' },
  --[[ 5 ]] { ' R', ' R', ' R', ' R', 'SR', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R' },
  --[[ 6 ]] { ' L', ' L', ' L', ' L', ' L', 'SL', ' L', ' L', ' L', ' L', ' L', ' L', ' L' },
  --[[ 7 ]] { ' R', ' R', ' R', ' R', ' R', ' R', 'SR', ' R', ' R', ' R', ' R', ' R', ' R' },
  --[[ 8 ]] { ' L', ' L', ' L', ' L', ' L', ' L', ' L', 'SL', ' L', ' L', ' L', ' L', ' L' },
  --[[ 9 ]] { ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', 'SR', ' R', ' R', ' R', ' R' },
  --[[ T ]] { ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', 'SL', ' L', ' L', ' L' },
  --[[ J ]] { ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', 'SR', ' R', ' R' },
  --[[ Q ]] { ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', ' L', 'SL', ' L' },
  --[[ K ]] { ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', ' R', 'SR' },
  --[[ B ]] { 'AR', 'KR', 'QL', 'JR', 'TL', '9R', '8L', '7R', '6L', '5R', '4L', '3R', '2L' },
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
      
      while state ~= nil do
        -- get current symbol and next state
        local current_symbol = nil
        local next_state = nil
        -- note this may be nil
        local current_card = G.hand.cards[tape_index]
        if tape_index > #G.hands.cards then
          current_symbol = 'B'
          next_state = current_symbol %#G.jokers.cards + 1
        else
          current_symbol = current_card:get_id()
          next_state = current_symbol % #G.jokers.cards + 1;
          -- terminate on a stone card
          if current_card.ability.effect ~= 'Stone Card'
            next_state = nil
            break
          end
        end
        -- given current symbol, read the write value and the tape direction
        local write_symbol = sub(turing_state_transitions[current_symbol][state], 1, 2)
        local tape_direction = sub(turing_state_transitions[current_symbol][state], 2)
        
        -- store edition of current state as we'll need to write this to a card
        local current_state_edition = G.jokers.cards[state].edition
        -- todo does this work or do I need to check before access
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
