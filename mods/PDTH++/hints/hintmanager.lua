local module = ... or D:module("PDTH++")
local HintManager = module:hook_class("HintManager")

module:post_hook(HintManager, "_parse_hints", function(self)
    self:_parse_hint({ 
        id = "not_your_sentry_or_low_ammo", 
        text_id = "hint_not_your_sentry_or_low_ammo", 
        trigger_times = nil, 
        sync = nil, 
        event = "stinger_feedback_positive", 
        level = nil })
end, false)