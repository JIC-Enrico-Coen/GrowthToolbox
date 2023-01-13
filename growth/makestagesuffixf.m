function s = makestagesuffixf( t )
%s = makestagesuffixf( t )
% Convert a number T to a stage suffix S.  T is converted to a stage label,
% and the stage prefix prepended. If T is a singoe value, a single string
% is returned, otherwise a cell array of strings.

    global gMISC_GLOBALS;
    s = append( gMISC_GLOBALS.stageprefix, stageTimeToText( t ) );
end

