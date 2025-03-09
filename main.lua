function create_ante_preview()
    G.round_eval:get_UIE_by_ID("next_ante_preview").children = {}
    local blind = G.P_BLINDS.bl_small
    local blind_sprite = AnimatedSprite(0, 0, 1, 1,
        G.ANIMATION_ATLAS[blind.atlas] or G.ANIMATION_ATLAS.blind_chips, blind.pos)
    blind_sprite:define_draw_steps({ { shader = 'dissolve', shadow_height = 0.05 }, { shader = 'dissolve' } })
    local blind_amt = get_blind_amount(G.GAME.round_resets.blind_ante + 1)
        * blind.mult * G.GAME.starting_params.ante_scaling
    local tag = G.P_TAGS[get_next_tag_key()]
    local tag_sprite = Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS[tag.atlas] or G.ASSET_ATLAS.tags, tag.pos)
    tag_sprite:define_draw_steps({ { shader = 'dissolve', shadow_height = 0.05 }, { shader = 'dissolve' } })
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
                        {
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
    blind = G.P_BLINDS.bl_big
    blind_sprite = AnimatedSprite(0, 0, 1, 1,
        G.ANIMATION_ATLAS[blind.atlas] or G.ANIMATION_ATLAS.blind_chips, blind.pos)
    blind_sprite:define_draw_steps({ { shader = 'dissolve', shadow_height = 0.05 }, { shader = 'dissolve' } })
    blind_amt = get_blind_amount(G.GAME.round_resets.blind_ante + 1)
        * blind.mult * G.GAME.starting_params.ante_scaling
    tag = G.P_TAGS[get_next_tag_key()]
    tag_sprite = Sprite(0, 0, 0.4, 0.4, G.ASSET_ATLAS[tag.atlas] or G.ASSET_ATLAS.tags, tag.pos)
    tag_sprite:define_draw_steps({ { shader = 'dissolve', shadow_height = 0.05 }, { shader = 'dissolve' } })
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
                        {
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
    blind = get_new_boss()
    G.GAME.bosses_used[blind] = G.GAME.bosses_used[blind] - 1
    blind = G.P_BLINDS[blind]
    blind_sprite = AnimatedSprite(0, 0, 1, 1,
        G.ANIMATION_ATLAS[blind.atlas] or G.ANIMATION_ATLAS.blind_chips, blind.pos)
    blind_sprite:define_draw_steps({ { shader = 'dissolve', shadow_height = 0.05 }, { shader = 'dissolve' } })
    blind_amt = get_blind_amount(G.GAME.round_resets.blind_ante + 1)
        * blind.mult * G.GAME.starting_params.ante_scaling
    G.round_eval:add_child(
        {
            n = G.UIT.C,
            nodes = {
                { n = G.UIT.O, config = { object = blind_sprite } },
                { n = G.UIT.R, config = { align = "ct" },         nodes = { { n = G.UIT.O, config = { object = get_stake_sprite(G.GAME.stake, 0.4) } }, { n = G.UIT.T, config = { text = number_format(blind_amt), colour = G.C.RED, scale = score_number_scale(0.8, blind_amt) } }, } },
            }
        },
        G.round_eval:get_UIE_by_ID("next_ante_preview"))
end

local evaluate_round_hook = G.FUNCS.evaluate_round
function G.FUNCS.evaluate_round()
    evaluate_round_hook()
    if G.GAME.blind.boss then
        G.E_MANAGER:add_event(Event({
            func = function()
                local random_state = copy_table(G.GAME.pseudorandom)
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
                G.GAME.pseudorandom = random_state
                return true
            end
        }))
    end
end
