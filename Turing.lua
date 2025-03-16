SMODS.Atlas {
  key = "Turing",
  path = "turing.png",
  px = 71,
  py = 95
}

-- [card symbol][joker index] = 'rank to write'..'tape move direction'
turing_state_transitions = {
  ----------|  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  10 |  11 |  12 |  13 | (joker state)
  --[[ A ]] { 'SR', '3R', '4R', '5R', '6R', '7R', '8R', '9R', 'TR', 'JR', 'QR', 'KR', 'AR' },
  --[[ 2 ]] { '3L', 'SL', '5L', '6L', '7L', '8L', '9L', 'TL', 'JL', 'QL', 'KL', 'AL', '2L' },
  --[[ 3 ]] { '4R', '5R', 'SR', '7R', '8R', '9R', 'TR', 'JR', 'QR', 'KR', 'AR', '2R', '3R' },
  --[[ 4 ]] { '5L', '6L', '7L', 'SL', '9L', 'TL', 'JL', 'QL', 'KL', 'AL', '2L', '3L', '4L' },
  --[[ 5 ]] { '6R', '7R', '8R', '9R', 'SR', 'JR', 'QR', 'KR', 'AR', '2R', '3R', '4R', '5R' },
  --[[ 6 ]] { '7L', '8L', '9L', 'TL', 'JL', 'SL', 'KL', 'AL', '2L', '3L', '4L', '5L', '6L' },
  --[[ 7 ]] { '8R', '9R', 'TR', 'JR', 'QR', 'KR', 'SR', '2R', '3R', '4R', '5R', '6R', '7R' },
  --[[ 8 ]] { '9L', 'TL', 'JL', 'QL', 'KL', 'AL', '2L', 'SL', '4L', '5L', '6L', '7L', '8L' },
  --[[ 9 ]] { 'TR', 'JR', 'QR', 'KR', 'AR', '2R', '3R', '4R', 'SR', '6R', '7R', '8R', '9R' },
  --[[ T ]] { 'JL', 'QL', 'KL', 'AL', '2L', '3L', '4L', '5L', '6L', 'SL', '8L', '9L', 'TL' },
  --[[ J ]] { 'QR', 'KR', 'AR', '2R', '3R', '4R', '5R', '6R', '7R', '8R', 'SR', 'TR', 'JR' },
  --[[ Q ]] { 'KL', 'AL', '2L', '3L', '4L', '5L', '6L', '7L', '8L', '9L', 'TL', 'SL', 'QL' },
  --[[ K ]] { 'AR', '2R', '3R', '4R', '5R', '6R', '7R', '8R', '9R', 'TR', 'JR', 'QR', 'SR' },
B=--[[ B ]] { 'S_', 'A_', 'K_', 'Q_', 'S_', 'J_', 'T_', '9_', 'S_', '8_', '7_', '6_', 'S_' },
}

function turing_step(state, tape_index, iterations)
  if state == nil then
    return nil
  end
  -- get current symbol and next state
  local current_symbol = nil
  local next_state = nil
  -- note this may be nil
  local current_card = nil
  -- tape_index in [, #G.hand.cards] means card is there, otherwise it's blank
  if tape_index > #G.hand.cards or tape_index < 1 then
    current_symbol = 'B'
    -- todo state transition from a blank symbol == increment state?
    -- todo testing: blank sends to state end? keep getting loops
    next_state = ((state) % #G.jokers.cards) + 1
  else
    current_card = G.hand.cards[tonumber(tape_index)]
    current_symbol = current_card:get_id()
    if current_symbol == 14 then current_symbol = 1 end
    next_state = (current_symbol % #G.jokers.cards) + 1;
    -- terminate on a stone card
    if current_card.ability.effect == 'Stone Card' then
      return nil
    end
  end
  
  -- aces stored at 1 not 14
  
  
  -- given current symbol, read the write value and the tape direction
  local write_symbol = string.sub(turing_state_transitions[current_symbol][state], 1, 1)
  local tape_direction_string = string.sub(turing_state_transitions[current_symbol][state], 2)
  local tape_direction = 0
  if tape_direction_string == 'L' then
    tape_direction = -1
  elseif tape_direction_string == 'R' then
    tape_direction = 1
  end
    
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
      nil, -- G.hand,
      nil,
      nil,
      {G.C.SET.Default}
    )
    -- todo this doesn't put left cards on the right spot, seems to always add right-
    -- can probably change the state machine to just not do that?
    G.hand:emplace(current_card, tape_index, false)
  end

  local next_tape_index = tape_index + tape_direction;
  local log = "i: "..iterations
  log = log.." T_i: "..tape_index.." T_i+1: "..next_tape_index
  log = log.." Q_i: "..state.." Q_i+1: "..next_state
  log = log.." S_i: "..current_symbol.." S_w: "..write_symbol
  sendInfoMessage(log)

  -- add the edition to the existing/new card if needed
  e = Event({
    func = function()
      -- can happen on stone I think?
      if current_card.base.suit ~= nil then
        local suit_prefix = string.sub(current_card.base.suit, 1, 1)..'_'
        sendInfoMessage('Setting card to '..suit_prefix..write_symbol)
        current_card:set_base(G.P_CARDS[suit_prefix..write_symbol])
      end
      current_card:juice_up()
      if write_symbol == 'S' then
        current_card:set_ability(G.P_CENTERS['m_stone']);
      elseif current_state_edition ~= nil then
        current_card:set_edition(current_state_edition, true, true)
      end
      card_eval_status_text(current_card, 'extra', nil, nil, nil, {message = "Programmed!"})
      turing_step(next_state, next_tape_index, iterations + 1)
      return true
    end
  })
  G.E_MANAGER:add_event(e)
end


SMODS.Joker {
  key = "turingjoker",
  loc_txt = {
    name = "Turing",
    text = {
      "{C:attention}Reprograms{} played cards",
      "based on Joker editions."
    }
  },
  rarity = 4,
  atlas = "Turing",
  pos = { x= 0, y = 0 },
  soul_pos = { x=1, y=0 },
  cost = 11,
  -- Scoring calculation
  calculate = function(self, card, context)
    if context.before then
      local state = 1
      for k,v in ipairs(G.jokers.cards) do
        if v == card then
          state = k
        end
      end
      local tape_index = 1
      local iterations = 1

      
      turing_step(state, tape_index, iterations)
      playing_card_joker_effects({true})

      return {
        message = 'Program complete!'
      }
    end
  end
}
