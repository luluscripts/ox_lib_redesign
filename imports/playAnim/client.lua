
---@alias AnimationFlags number

---@alias ControlFlags number

---@param ped number
---@param animDictionary string
---@param animationName string
---@param blendInSpeed? number Defaults to 8.0
---@param blendOutSpeed? number Defaults to -8.0
---@param duration? integer Defaults to -1
---@param animFlags? AnimationFlags
---@param startPhase? number
---@param phaseControlled? boolean
---@param controlFlags? integer
---@param overrideCloneUpdate? boolean
function lib.playAnim(ped, animDictionary, animationName, blendInSpeed, blendOutSpeed, duration, animFlags, startPhase, phaseControlled, controlFlags, overrideCloneUpdate)
    lib.requestAnimDict(animDictionary)
    ---@diagnostic disable-next-line: param-type-mismatch
    TaskPlayAnim(ped, animDictionary, animationName, blendInSpeed or 8.0, blendOutSpeed or -8.0, duration or -1, animFlags or 0, startPhase or 0.0, phaseControlled or false, controlFlags or 0, overrideCloneUpdate or false)
    RemoveAnimDict(animDictionary)
end

return lib.playAnim
