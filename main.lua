function predict_next_ante()
    local small_tag = get_next_tag_key()
    local big_tag = get_next_tag_key()
    local boss = get_new_boss()
    G.GAME.bosses_used[boss] = G.GAME.bosses_used[boss] - 1
    return { Small = { blind = "bl_small", tag = small_tag }, Big = { blind = "bl_big", tag = big_tag }, Boss = { blind = boss } }
end

function create_ante_preview()
    G.round_eval:get_UIE_by_ID("next_ante_preview").children = {}
    local random_state = copy_table(G.GAME.pseudorandom)
    local prediction = predict_next_ante()
    for _, choice in ipairs({ "Small", "Big", "Boss" }) do
        if prediction[choice] then
            local blind = G.P_BLINDS[prediction[choice].blind]
            local blind_sprite = AnimatedSprite(0, 0, 1, 1,
                G.ANIMATION_ATLAS[blind.atlas] or G.ANIMATION_ATLAS.blind_chips, blind.pos)
            blind_sprite:define_draw_steps({ { shader = 'dissolve', shadow_height = 0.05 }, { shader = 'dissolve' } })
            local blind_amt = get_blind_amount(G.GAME.round_resets.blind_ante + 1)
                * blind.mult * G.GAME.starting_params.ante_scaling
            local tag = prediction[choice].tag
            local tag_sprite
            if tag then
                local tag_object
                local hands = {} -- Orbital tag is weird as hell
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then table.insert(hands, k) end
                end
                G.orbital_hand = pseudorandom_element(hands, pseudoseed('orbital'))
                tag_object = Tag(tag, nil, choice)
                G.orbital_hand = nil
                _, tag_sprite = tag_object:generate_UI(0.4)
            end
            G.round_eval:add_child({
                    n = G.UIT.C,
                    nodes = { {
                        n = G.UIT.R,
                        nodes = {
                            { n = G.UIT.O, config = { object = blind_sprite } },
                            {
                                n = G.UIT.C,
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cl" },
                                        nodes = {
                                            { n = G.UIT.O, config = { object = get_stake_sprite(G.GAME.stake, 0.4) } },
                                            { n = G.UIT.T, config = { text = number_format(blind_amt), colour = G.C.RED, scale = score_number_scale(0.8, blind_amt) } }
                                        }
                                    },
                                    tag and {
                                        n = G.UIT.R,
                                        config = { align = "cl" },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = "or ", colour = G.C.WHITE, scale = 0.4 } },
                                            { n = G.UIT.O, config = { id = "tag_sprite", object = tag_sprite } },
                                        }
                                    },
                                },
                            },
                        }
                    } }
                },
                G.round_eval:get_UIE_by_ID("next_ante_preview"))
            if choice ~= "Boss" then
                G.round_eval:add_child({ n = G.UIT.B, config = { w = 0.25, h = 0 } },
                    G.round_eval:get_UIE_by_ID("next_ante_preview"))
            end
        end
    end
    G.GAME.pseudorandom = random_state
end

local evaluate_round_hook = G.FUNCS.evaluate_round
function G.FUNCS.evaluate_round()
    evaluate_round_hook()
    if G.GAME.blind_on_deck == "Boss" then
        G.E_MANAGER:add_event(Event({
            func = function()
                G.round_eval:add_child(
                    {
                        n = G.UIT.C,
                        config = { r = 0.1, colour = G.C.BLACK, emboss = 0.05 },
                        nodes = {
                            { n = G.UIT.R, config = { padding = 0.1 },                          nodes = { { n = G.UIT.T, config = { text = "Next Ante:", colour = G.C.WHITE, scale = 0.5 } } } },
                            { n = G.UIT.R, config = { id = "next_ante_preview", padding = 0.1 } },
                        }
                    },
                    G.round_eval:get_UIE_by_ID("eval_bottom"))
                create_ante_preview()
                return true
            end
        }))
    end
end
