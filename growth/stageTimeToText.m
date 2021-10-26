function s = stageTimeToText( t )
%s = stageTimeToText( t )
% Convert a number T to a stage label S.  T is converted to a string,
% and padded out to a fixed length with leading and trailing zeros.  The
% decimal point is replaced by a 'd' and if the number is negative an 'm'
% is prefixed.
%
% If T is a list of numbers, s will be a cell array of strings.
%
%   See also: stageStringToReal.

    if length(t)==1
        s = make1stagelabel( t );
    else
        s = cell(1,length(t));
        for i=1:length(t)
            s{i} = make1stagelabel( t(i) );
        end
    end
end

function s = make1stagelabel( t )
    global gMISC_GLOBALS;
    s = sprintf( '%0*.10f', 11+gMISC_GLOBALS.stagesuffixlength, t );
    s = regexprep( s, '0*$', '' );
    s = regexprep( s, '\.', 'd' );
    s = regexprep( s, '-', 'm' );
    s = regexprep( s, 'd$', '' );
end

