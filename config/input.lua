function formatNumberComma(number)
    local finalOutput =  format_int(number)
   
    return finalOutput
end

function format_int(number)
  --thanks to https://stackoverflow.com/questions/10989788/format-integer-in-lua answer by Bert Kiers
  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1".._G.language:getText("thousandsDelimiter"))

  -- reverse the int-string back remove an optional comma and put the 
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^".._G.language:getText("thousandsDelimiter"), "") .. fraction
end