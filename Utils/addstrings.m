function s = addstrings( s, ss )
%s = addstrings( s, ss )
%   Concatenate the strings in the cell array ss onto the end of s, each
%   with an added newline.
    s = [ s, joinstrings( char(10), ss ), char(10) ];
end
