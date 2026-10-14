local U = require("src.util")
local Training = {}
Training.__index = Training
function Training.new(settings)
    local self = setmetatable(
        { settings = settings, deaths = 0, attempt = 0, history = {}, notice = "" },
        Training
    )
    self:reset()
    return self
end

function Training:reset()
    self.attempt = self.attempt + 1
    self.stats = { time = 0, realTime = 0, received = 0, dealt = 0, hits = 0, steps = 0 }
    self.result = nil
    self.notice = ""
    self.noticeTimer = 0
end

function Training:update(dt)
    self.stats.time = self.stats.time + dt
    self.noticeTimer = math.max(0, self.noticeTimer - dt)
end

function Training:feedback(text)
    self.notice = text
    self.noticeTimer = 1.7
end

function Training:dps()
    return self.stats.time > 0 and self.stats.dealt / self.stats.time or 0
end

function Training:finish(reason)
    if self.result then
        return
    end
    if reason == "Derrota" then
        self.deaths = self.deaths + 1
    end
    local s = U.copy(self.stats)
    s.reason, s.mode, s.skill = reason, self.settings.mode, self.settings.practiceSkill
    s.attempt, s.deaths = self.attempt, self.deaths
    s.dps = self:dps()
    s.speed, s.frequency, s.difficulty =
        self.settings.speed, self.settings.frequency, self.settings.difficulty
    self.result = s
    self.history[#self.history + 1] = s
    if #self.history > 100 then
        table.remove(self.history, 1)
    end
    self:export()
end

function Training:export()
    if not love or not love.filesystem then
        return
    end
    local lines = {
        "tentativa,motivo,modo,habilidade,tempo_sim_s,tempo_real_s,dano_recebido,dano_causado,dps,acertos_recebidos,passos,mortes,velocidade,frequencia,dificuldade",
    }
    for _, s in ipairs(self.history) do
        local values = {
            s.attempt,
            s.reason,
            s.mode,
            s.skill,
            string.format("%.3f", s.time),
            string.format("%.3f", s.realTime),
            s.received,
            s.dealt,
            string.format("%.2f", s.dps),
            s.hits,
            s.steps,
            s.deaths,
            s.speed,
            s.frequency,
            s.difficulty,
        }
        local row = {}
        for _, v in ipairs(values) do
            row[#row + 1] = U.csv(v)
        end
        lines[#lines + 1] = table.concat(row, ",")
    end
    return love.filesystem.write("attempts.csv", table.concat(lines, "\n") .. "\n")
end
return Training
