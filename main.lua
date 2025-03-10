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
    G.GAME.pseudorandom = random_state
    for _, choice in ipairs({ "Small", "Big", "Boss" }) do
        local blind = G.P_BLINDS[prediction[choice].blind]
        local blind_sprite = AnimatedSprite(0, 0, 1, 1,
            G.ANIMATION_ATLAS[blind.atlas] or G.ANIMATION_ATLAS.blind_chips, blind.pos)
        blind_sprite:define_draw_steps({ { shader = 'dissolve', shadow_height = 0.05 }, { shader = 'dissolve' } })
        local blind_amt = get_blind_amount(G.GAME.round_resets.blind_ante + 1)
            * blind.mult * G.GAME.starting_params.ante_scaling
        local tag = G.P_TAGS[prediction[choice].tag]
        local tag_sprite
        if tag then
            tag_sprite = Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS[tag.atlas] or G.ASSET_ATLAS.tags, tag.pos)
            tag_sprite:define_draw_steps({ { shader = 'dissolve', shadow_height = 0.05 }, { shader = 'dissolve' } })
        end
        G.round_eval:add_child(
            {
                n = G.UIT.C,
                nodes = {
                    { n = G.UIT.O, config = { object = blind_sprite } },
                    {
                        n = G.UIT.R,
                        config = { align = "cl" },
                        nodes = {
                            { n = G.UIT.R, config = { align = "ct" }, nodes = { { n = G.UIT.O, config = { object = get_stake_sprite(G.GAME.stake, 0.4) } }, { n = G.UIT.T, config = { text = number_format(blind_amt), colour = G.C.RED, scale = score_number_scale(0.8, blind_amt) } } } },
                            tag and {
                                n = G.UIT.C,
                                config = { align = "cm" },
                                nodes = {
                                    { n = G.UIT.T, config = { text = "or ", colour = G.C.WHITE, scale = 0.4 } },
                                    { n = G.UIT.O, config = { object = tag_sprite } },
                                }
                            },
                        }
                    },
                    { n = G.UIT.B, config = { h = 0, w = 1 } },
                }
            },
            G.round_eval:get_UIE_by_ID("next_ante_preview"))
    end
    local all_blind_uis = G.round_eval:get_UIE_by_ID("next_ante_preview").children
    table.remove(all_blind_uis[#all_blind_uis])
end

local evaluate_round_hook = G.FUNCS.evaluate_round
function G.FUNCS.evaluate_round()
    evaluate_round_hook()
    if G.GAME.blind_on_deck == "Boss" then
        G.E_MANAGER:add_event(Event({
            func = function()
                G.round_eval:add_child(
                    {
                        n = G.UIT.R,
                        config = { padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05 },
                        nodes = {
                            { n = G.UIT.R, nodes = { { n = G.UIT.T, config = { text = "Next Ante:", colour = G.C.WHITE, scale = 0.5 } } } },
                            { n = G.UIT.C, config = { id = "next_ante_preview" } },
                        }
                    },
                    G.round_eval:get_UIE_by_ID("eval_bottom"))
                create_ante_preview()
                return true
            end
        }))
    end
end
