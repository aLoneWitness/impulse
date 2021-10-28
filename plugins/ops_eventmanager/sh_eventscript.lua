IES = IES or {}

local LANG = {}
LANG.NEWLINE = "\n"
LANG.ESCAPER = "#"
LANG.COMMENT = "//"
LANG.OR = "?"
LANG.EQ = ":"
LANG.SEP = ","
LANG.GET = "@"
LANG.STR = [["]]
LANG.STR2 = [[']]
LANG.UID_START = "("
LANG.UID_END = ")"
LANG.PROP_START = "{"
LANG.PROP_END = "}"

local COMP_SKIPLINE = 1
local COMP_REPROCESS = 2
local COMP_HALT = 3
local COMP_CONSTRUCTING = ""
local COMP_GOTOTERM = ""
local COMP_GOTOPARSER = ""
local COMP_CURLINE = ""
local COMP_LINESTRBUFFER = {}
local COMP_CURWORDPOS = 0
local VAR_PARSED = 99
local CALL
local MAKECALL
local MAKEPARSE 
local MAKEVAR 
local MAKEWAIT 
local MACRO 
local MAKETAG 
local PARSER
local TAGS
local VARS

local function Ex(no, msg)
    local red = Color(246, 131, 0)

    MsgC(red, "------------------------------\n")
    MsgC(red, "|[IES ERROR]\n")
    MsgC(red, "|    Line: "..no.."\n")
    MsgC(red, "|    "..msg, "\n")
    MsgC(red, "------------------------------\n")
end

local function find(word, t)
    return string.find(word, t, nil, true)
end

local function trim(word)
    return string.Trim(word)
end

local function VarCheck(no, word)
    if string.StartWith(word, LANG.GET) then
        local name = string.sub(word, 2)

        if VARS[name] then
            return VARS[name]
        end

        Ex(no, "Can not find VAR called '"..word.."'")
        return COMP_HALT
    end

    return word
end

local parserWorkers = {
    ["String"] = function(word, no)
        print("str parser")
        local ender = find(word, LANG.STR)

        if not ender then
            return COMP_REPROCESS, {PARSER = true}
        end

        local val = table.remove(COMP_LINESTRBUFFER, 1)

        return VAR_PARSED, val
    end,
    ["Vector"] = function(word, no) -- aliases: Angle
        if not PARSER.Opened then
            local opener = find(word, "(")

            if opener then
                PARSER.Opened = true
            end

            return COMP_REPROCESS, {PARSER = true, SUB_WORD = string.sub(word, opener + 1)}
        end

        if PARSER.NeedsComma then
            local comma = find(word, LANG.SEP)

            if comma then
                PARSER.NeedComma = false
                PARSER.NeedVal = true
            end

            return COMP_REPROCESS, {PARSER = true, SUB_WORD = string.sub(word, comma + 1)}
        end

        if PARSER.NeedVal then
            local num = tonumber(word)

            if not num then
                Ex(no, "Expected number inside Vector, got '"..word.."'")
                return COMP_HALT
            end

            if PARSER.Values and #PARSER.Values >= 3 then
                Ex(no, "Too many values passed to Vector, expected 3")
                return COMP_HALT
            end

            PARSER.Values = PARSER.Values or {}
            PARSER.Values[#PARSER.Values + 1] = num

            if #PARSER.Values != 3 then
                PARSER.NeedVal = false
                PARSER.NeedComma = true
            end

            return COMP_REPROCESS, {PARSER = true, SUB_WORD = string.sub(word, string.len(word))}
        end

        local ender = find(word, ")")

        if ender then
            PrintTable(PARSER)
            return VAR_PARSED, PARSER.Values
        end
    end

}

local function ParseVar(word, no)
    if PARSER and parserWorkers[PARSER.Current] then
        local a,b = parserWorkers[PARSER.Current](word, no)
        print("A: "..a)
        print("B: "..b)
        return a, b
    end

    local num = tonumber(word)
    if num then
        PARSER = {}
        PARSER.Number = true
        PARSER = nil
        return VAR_PARSED, num
    end

    if string.StartWith(word, LANG.STR) then
        print("str")
        PARSER = {}
        PARSER.Current = "String"

        return COMP_REPROCESS, {PARSER = true}
    end

    if string.StartWith(word, "Vector") or string.StartWith(word, "Angle") then
        PARSER = {}
        PARSER.Current = "Vector"

        return COMP_REPROCESS, {PARSER = true}
    end
end

local function DoCall(word, no)
    CALL = CALL or {}

    if not CALL.NAME then
        local split = string.Split(word, LANG.UID_START)
        local splitx = string.Split(split[1], LANG.PROP_START)
        local x = split[1]

        if not impulse.Ops.EventManager.Config.Events[x] then
            Ex(no, "Can not find event matching '"..x.."'")
            return COMP_HALT
        end

        CALL.NAME= x
        COMP_CONSTRUCTING = "CALL"

        local found = find(word, LANG.UID_START)

        if not found then
            found = find(word, LANG.PROP_START)
        end

        if found then
            return COMP_REPROCESS, {SUB_WORD = string.sub(word, found)}
        end
    end

    if not CALL.UID and string.StartWith(word, LANG.UID_START) then
        local findEnd = find(word, LANG.UID_END)

        if not findEnd then
            Ex(no, "Can not find UID bracket close '"..word.."'")
            return COMP_HALT
        end

        local varName = string.sub(word, 2, findEnd-1)

        CALL.UID = varName

        local found = find(word, LANG.PROP_START)

        if found then
            return COMP_REPROCESS, {SUB_WORD = string.sub(word, found)}
        end
    end

    if not CALL.PROP and (string.StartWith(word, LANG.PROP_START) or CALL.PROP_OPEN) then
        CALL.PROP_TMP = CALL.PROP_TMP or ""
        CALL.PROP_OPEN = true
        local findEnd = find(word, LANG.PROP_END)

        if findEnd then
            local varName = string.sub(word, 1, findEnd)
            CALL.PROP = CALL.PROP_TMP..varName
            CALL.PROP_TMP = nil
            CALL.PROP_OPEN = false
        else
            CALL.PROP_TMP = CALL.PROP_TMP..word
        end
    end
end

LANG.TERMS = {
    macro = {
        Handler = function(word, no)
            if not word then
                if MACRO then
                    Ex(no, "Nested macros are not supported")
                    return COMP_HALT
                end
                MACRO = {}
                MACRO.START_LINE = no + 1

                return COMP_REPROCESS, {TERM = "macro"}
            end

            if not MACRO.NAME then
                if word == "" then
                    Ex(no, "Can not find macro name")
                    return COMP_HALT
                end

                MACRO.NAME = word

                local split = find(word, LANG.PROP_START)

                if split then
                    return COMP_REPROCESS, {TERM = "macro", SUB_WORD = string.sub(word, split)}
                end

                return
            end

            if not MACRO.PROPS and (string.StartWith(word, LANG.PROP_START) or MACRO.PROP_OPEN) then
                MACRO.PROP_TMP = MACRO.PROP_TMP or ""
                MACRO.PROP_OPEN = true
                local split = find(word, LANG.PROP_END)

                if split then
                    MACRO.PROP_OPEN = false 
                    MACRO.PROP = MACRO.PROP_TMP..string.sub(word, 1, split)
                    MACRO.PROP_TMP = nil
                else
                    MACRO.PROP_TMP = MACRO.PROP_TMP..word
                end

                return COMP_REPROCESS, {TERM = "macro"}
            end

            
            return COMP_SKIPLINE
        end,
        OnLineDone = function(no)
            if not MACRO.NAME then
                Ex(no, "Can not find macro name")
                return COMP_HALT
            end

            if MACRO.PROP_OPEN then
                Ex(no, "Can not find macro property bracket close")
                return COMP_HALT
            end

            PrintTable(MACRO)
        end
    },
    ["end"] = {
        Handler = function(word, no)
            if not MACRO then
                Ex(no, "Can not find start of statment for end")
                return COMP_HALT
            end

            MACRO.END_LINE = no - 1

            PrintTable(MACRO)

            MACRO = nil

            return COMP_SKIPLINE
        end
    },
    call = {
        Handler = function(word, no)
            if not word then
                MAKECALL = {}
                return COMP_REPROCESS, {TERM = "call"}
            end

            MAKECALL.HasCall = true

            return DoCall(word, no) or COMP_SKIPLINE
        end,
        OnLineDone = function(no)
            if not MAKECALL.HasCall then
                Ex(no, "Call was made but no arguments were provided")
                return COMP_HALT
            end
        end
    },
    call_async = {
        Handler = function(word, no)
            if not word then
                MAKECALL = {}
                return COMP_REPROCESS, {TERM = "call_async"}
            end

            MAKECALL.HasCall = true
            MAKECALL.ASync = true

            return DoCall(word, no) or COMP_SKIPLINE
        end,
        OnLineDone = function(no)
            if not MAKECALL.HasCall then
                Ex(no, "ASync Call was made but no arguments were provided")
                return COMP_HALT
            end
        end
    },
    wait = {
        Handler = function(word, no)
            if not word then
                MAKEWAIT = {}
                return COMP_REPROCESS, {TERM = "wait"}
            end

            local n = tonumber(word)

            if not n then
                Ex(no, "Wait value must be a valid number")
                return COMP_HALT
            end

            MAKEWAIT.HasWait = true
            MAKEWAIT.Wait = n

            PrintTable(MAKEWAIT)

            return COMP_SKIPLINE
        end,
        OnLineDone = function(no)
            if not MAKEWAIT.HasWait then
                Ex(no, "Wait was made but no arguments were provided")
                return COMP_HALT
            end
        end
    },
    tag = {
        Handler = function() 
            return COMP_SKIPLINE
        end
    },
    var = {
        Handler = function(word, no) 
            print("var call")
            if not word then
                MAKEVAR = {}
                MAKEVAR.NAME_START = true
                print("make var")
                return COMP_REPROCESS, {TERM = "var"}
            end
    
            if not MAKEVAR.NAME and MAKEVAR.NAME_START then
                if word == "" then
                    Ex(no, "Can not find VAR name")
                    return COMP_HALT
                end
    
                MAKEVAR.NAME = word
                MAKEVAR.NAME_START = false
                return COMP_REPROCESS, {TERM = "var"}
            end
    
            if MAKEVAR.NAME and not MAKEVAR.VALUE then
                local r, data = ParseVar(word, no)

                print("woop")

                print(r)
                print(data)

                if r and r == VAR_PARSED then
                    MAKEVAR.VALUE = data
                    return COMP_SKIPLINE
                else
                    return r, data
                end
            end
    
            print(word)
            --SUB_WORD = string.TrimLeft(word, )
            return COMP_REPROCESS, {TERM = "var"}
        end,
        OnLineDone = function(no)
            if not MAKEVAR.NAME then
                Ex(no, "Can not find VAR name")
                return COMP_HALT
            end

            if not MAKEVAR.VALUE then
                Ex(no, "No value provided for VAR '"..MAKEVAR.NAME.."'")
                return COMP_HALT
            end
            
            VARS[MAKEVAR.NAME] = MAKEVAR.VALUE
            print("var done")
            PrintTable(MAKEVAR)
        end
    },
    start = {
        Handler = function() 
            return COMP_SKIPLINE
        end
    },
    ["break"] = {
        Handler = function() 
            return COMP_HALT
        end
    },
}

local function DoString(string, no)

end

local function DoTerm(macro, no)
    local x = string.sub(macro, 2) -- remove #
    x = string.Trim(x, " ")

    print("trying to term "..x)

    local term = LANG.TERMS[x]

    if term then
        return term.Handler(nil, no)
    else
        Ex(no, "Can not find term matching '"..x.."'")
        return COMP_HALT
    end
end

local function DoEvent(word, no)
    return DoCall(word, no)
end


local function DoWord(word, no)
    word = trim(word)

    if word == "" or word == "" then
        return
    end

    print("doing a word: "..word)

    if string.StartWith(word, LANG.COMMENT) then
        print("found comment!")
        return COMP_SKIPLINE
    end

    word = VarCheck(no, word)

    if COMP_CONSTRUCTING == "CALL" then
        return DoCall(word, no)
    end

    if COMP_GOTOPARSER then
        return ParseVar(word, no)
    end

    if COMP_GOTOTERM and COMP_GOTOTERM != "" then
        print("going to "..COMP_GOTOTERM)
        return LANG.TERMS[COMP_GOTOTERM].Handler(word, no)
    end

    if string.StartWith(word, LANG.ESCAPER) then
        return DoTerm(word, no)
    end

    return DoEvent(word, no)
end

local function DoLine(line, no)
    if COMP_CONSTRUCTING != "MACRO" then -- macro is multi-line
        COMP_CONSTRUCTING = ""
    end

    line = string.Trim(line, " ")
    line = string.Trim(line, "\n")
    line = string.Trim(line, "\r") -- carriage return line feed support

    if line == "" then
        return -- empty line
    end

    COMP_CURLINE = line
    COMP_LINESTRBUFFER = {}
    local strOpen = false
    local strOpenPos = 0
    local strLastStart = -1

    local commentPos = find(line, LANG.COMMENT)

    local function strSearch(start)
        if start < strLastStart then
            return
        end

        strLastStart = start

        local find = string.find(line, LANG.STR, start, true)

        if find then
            if !commentPos or strOpen or find < commentPos then
                if strOpen then
                    local str = string.sub(line, strOpenPos, find)
                    table.insert(COMP_LINESTRBUFFER, str)
                    strOpen = false
                    strSearch(find + 1)
                    return
                end

                strOpen = true
                strOpenPos = find
                strSearch(find + 1)
            end
        end
    end

    strSearch(0)

    if strOpen then
        Ex(no, "String opened but did not end")
        return 101
    end

    local words = string.Explode(" ", line)

    local function caller(word, no)
        local act, data = DoWord(word, no)

        if not data or not data.TERM then
            COMP_GOTOTERM = nil
        end

        if act == COMP_SKIPLINE then
            return 100 -- continue
        elseif act == COMP_REPROCESS then
            COMP_GOTOTERM = data.TERM or nil -- route next word into term
            COMP_GOTOPARSER = data.PARSER or nil

            local s
            if data.SUB_WORD and data.SUB_WORD != "" then
                s = data.SUB_WORD or word
            end

            caller(data.SUB_WORD or word, no)
        elseif act == COMP_HALT then
            return 101 -- break
        end
    end

    print("doing line "..no)

    for x, word in pairs(words) do
        local r = caller(word, no) or 0

        print("ReturnCode: ", r)

        if r == 100 then
            return -- skip line
        elseif r == 101 then
            return 101
        end
    end

    if CALL and CALL.NAME then
        if CALL.PROP_OPEN then
            Ex(no, "Can not find PROP bracket close")
            return COMP_HALT    
        end

        print("making call")
        PrintTable(CALL)


        CALL = nil
    end
    
    if COMP_GOTOTERM then
        local term = LANG.TERMS[COMP_GOTOTERM]

        if term and term.OnLineDone then
            term.OnLineDone(no)
        end
    end

    COMP_GOTOTERM = nil
end

function IES.Compile(script)
    COMP_CONSTRUCTING = ""
    COMP_GOTOTERM = nil
    COMP_GOTOPARSER = nil
    CALL = {}
    VARS = {}
    TAGS = {}

    local lines = string.Explode(LANG.NEWLINE, script)

    for lineNo, line in pairs(lines) do
        local returnCode = DoLine(line, lineNo)

        if returnCode and returnCode == 101 then
            break
        end
    end

    if MACRO then
        Ex(MACRO.START_LINE - 1, "Can not find end for macro")
        return
    end

    return TAGS
end

if CLIENT then
    concommand.Add("ies_test", function()
        local x = file.Read("impulse/ops/eventmanager/test.ies", "DATA")

        IES.Compile(x)
    end)
end