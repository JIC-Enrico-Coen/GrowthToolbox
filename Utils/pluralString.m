function ps = pluralString( n, s, suffix )
%ps = pluralString( n, s, suffix )
%   Make a string consisting of the integer n followed by a space, followed
%   by s, made plural if necessary by addition of the suffix. The suffix
%   defaults to 's' unless s ends with an 's', 'x', or 'z', in which
%   case suffix defaults to 'es'.
%
%   If suffix begins with '^', then the rest of suffix is taken to be the
%   entire plural form. This handles irregular plurals such as goose/geese.
%
%   Examples
%
%   s          suffix      singular/plural
%   'frame'    (none)      frame/frames
%   'ferry'    (none)      ferry/ferries
%   'box'      (none)      box/boxes
%   'ox'       'en'        ox/oxen
%   'sheep'    ''          sheep/sheep
%   'mouse'    '^mice'     mouse/mice

    s1 = s;
    if nargin < 3
        if ~isempty(s) && ~isempty( find( 'sxz'==s(end), 1 ) )
            s2 = [ s 'es' ];
        elseif ~isempty(s) && (s(end)=='y')
            s2 = [ s(1:(end-1)) 'ies' ];
        else
            s2 = [ s 's' ];
        end
    elseif isempty(suffix)
        s2 = s;
    elseif suffix(1)=='^'
        s2 = suffix(2:end);
    else
        s2 = [s suffix];
    end
    ps = [ sprintf( '%d ', n ), boolchar( n==1, s1, s2 ) ];
end
