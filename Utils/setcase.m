function strings = setcase( whichcase, strings )
    if whichcase==-1
        strings = lower(strings);
    elseif whichcase==1
        strings = upper(strings);
    end
end