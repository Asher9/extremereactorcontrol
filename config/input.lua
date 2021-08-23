function formatNumberComma(number)
  --thanks to https://stackoverflow.com/questions/10989788/format-integer-in-lua answer by Bert Kiers


    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
  
    -- reverse the int-string and append a comma to all blocks of 3 digits
    int = int:reverse():gsub("(%d%d%d)", "%1,")
  
    -- reverse the int-string back remove an optional comma and put the 
    -- optional minus and fractional part back

    local finalOutput =  minus .. int:reverse():gsub("^,", "") .. fraction

    --update to use correct language delimiter.
    finalOutput = string.gsub(finalOutput, ".", "frac")
    finalOutput = string.gsub(finalOutput, ",", "thou")

    finalOutput = string.gsub(finalOutput, "frac", _G.language:getText("fractionDelimiter"))
    finalOutput = string.gsub(finalOutput, "thou", _G.language:getText("thousandsDelimiter"))

    return finalOutput
end
