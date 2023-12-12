function same = samestring( s1, s2 )
%same = samestring( s1, s2 )
%   Determine whether two strings are identical. s1 and s2 can be of type
%   'string' or 'char', independently. If they are of type 'char', they can
%   be of any shape. All that matters is that the number of characters be
%   the same and corresponding characters are identical.

    s1 = char(s1);
    s2 = char(s2);
    same = (numel(s1)==numel(s2)) && all(s1(:)==s2(:));
end
