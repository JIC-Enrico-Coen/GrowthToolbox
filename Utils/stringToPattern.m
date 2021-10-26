function p = stringToPattern( s )
%p = stringToPattern( s )
%   This returns a regular expression that matches the string given.  To do
%   this, a backslash is inserted before every character in s that has a
%   special meaning in regular expressions.
%
%   p is not bound to the beginning or end: it will match s wherever it
%   appears in a longer string.
%
%   The intended use of this is to allow an arbitrary string to appear
%   within a regular expression, by transforming it first.

    % C and Java programmers note: in Matlab strings, '\' is not a special
    % character in the syntax of strings.
    specialchars = '.[\(|^$*+?{';
    p = char(zeros(1,length(specialchars)*2));
    pi = 0;
    for i=1:length(s)
        sci = find( s(i)==specialchars, 1 );
        if ~isempty(sci)
            pi = pi+1;
            p(pi) = '\';
        end
        pi = pi+1;
        p(pi) = s(i);
    end
    p((pi+1):end) = '';
end
