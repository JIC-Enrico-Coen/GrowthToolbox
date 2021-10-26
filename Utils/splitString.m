function [toks,seps] = splitString( pat, str )
%[toks,seps] = splitString( pat, str )
%   Implementation of the Perl split() function.
%   Splits the string STR wherever the pattern PAT matches.
%   TOKS is a cell array of the strings between the matches.
%   SEPS is a cell array of the matching strings.
%   If the string begins or ends with a match, TOKS will correspondingly
%   begin or end with an empty string.  TOKS always contains one more
%   element than SEPS.

    if isempty(str)
        toks = {};
        return;
    end
    [ si, ei ] = regexp( str, pat, 'start', 'end' );
    seps = cell(length(si),1);
    for i=1:length(si)
        seps{i} = str( si(i):ei(i) );
    end
    si = [ (si-1), length(str) ];
    ei = [ 1 (ei+1) ];
    toks = cell(length(si),1);
    for i=1:length(si)
        toks{i} = str( ei(i):si(i) );
    end
%     for i=1:length(si)-1
%         seps{i} = str( (ei(i)+1):(si(i+1)-1) );
%     end
%     si
%     ei
end
