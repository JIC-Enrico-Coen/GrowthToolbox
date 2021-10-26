function ts = itemStringToSuffixPattern( is )
% Convert a stage suffix to a pattern that will match any equivalent stage
% suffix when used as an argument to ls() or dir().
    global gMISC_GLOBALS
    if any(is=='d')
        ts = regexprep( is, '([dD][0-9]*)', '$10*' );
    else
        ts = [ is, '(d0*)?' ];
    end
    if ts(1)=='-'
        minusprefix = '[mM]';
        ts = ts(2:end);
    else
        minusprefix = '';
    end
    ts = [ gMISC_GLOBALS.stageprefix, minusprefix, '0*', ts ];
end
