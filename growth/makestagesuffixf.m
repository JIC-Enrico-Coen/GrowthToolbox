function s = makestagesuffixf( t )
%s = makestagesuffixf( t )
% Convert a number T to a stage suffix S.  T is converted to a stage label,
% and the stage prefix prepended.

    global gMISC_GLOBALS;
    s = [ gMISC_GLOBALS.stageprefix, stageTimeToText( t ) ];
end

