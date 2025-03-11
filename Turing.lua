SMODS.Atlas {
  key = "Turing",
  path = "turing.png",
  px = 71,
  py = 95
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
  rarity = 3,
  atlas = "Turing",
  pos = { x= 0, y = 0 },
  cost = 11,
  -- Scoring calculation
  calculate = function(self, card, context)
    if context.before then      
      -- The turing machine joker is the starting state for the turing machine.
      -- The hand is the tape. 
      -- The machine reads the symbol (rank) at the head,
      -- writes the foil/holographic/polychrome effect on the current state joker to the tape.
      -- The next state is selected by the symbol (rank) at the head,
      -- the next state is the joker (current + rank-of-card) % number of jokers,
      -- except if the card is a stone card, in which case the computation halts
      -- todo negative goes backwards on the tape

      local state = card
      for _, v in ipairs(context.full_hand) do
        if state ~= nil then
          local symbol = v:get_id() -- todo what happens for a stone card here?
          local joker_index = symbol % #G.jokers.cards + 1;
          local next_state = G.jokers.cards[symbol % #G.jokers.cards + 1]
          local current_state_edition = state.edition
          state = next_state
          if current_state_edition ~= nil then
            -- todo doing this in the event manager below causes it to only apply after
            -- the hand is scored.
            -- but doing it without event as below shows the edition before the "Programmed" text pops up
            -- G.E_MANAGER:add_event(Event({
            --   trigger = 'immediate',
            --   delay = 1,
            --   func = function()
            --     v:juice_up()
            --     return true
            --   end
            -- }))
            v:juice_up()
            card_eval_status_text(v, 'extra', nil, nil, nil, {message = "Programmed!"})
            v:set_edition(current_state_edition, true, true)
          end
        end
      end
      playing_card_joker_effects({true})

      return {
        message = "Program complete!"
      }
    end
  end
}

-- NB9D2VX1 (jokur pak)