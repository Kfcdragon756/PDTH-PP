local module = ... or D:module("PDTH++")
local NetworkMatchMakingSTEAM = module:hook_class("NetworkMatchMakingSTEAM")

NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = string.format("%s-%s", module:id(), module:version())