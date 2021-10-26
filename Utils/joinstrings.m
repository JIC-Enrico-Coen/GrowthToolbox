function js = joinstrings( s, varargin )
%js = joinstrings( s, ss )
%   ss is a cell array of strings.  Concatenate all members of ss together,
%   separated by the string s.

    if nargin < 2
        js = '';
        return;
    end

    if iscell( varargin{1} )
        ss = varargin{1};
    else
        ss = varargin;
    end

    if isempty(ss)
        js = '';
        return;
    end
    totlen = 0;
    for i=1:length(ss)
        totlen = totlen + length(ss{i});
    end
    totlen = totlen + length(s) * (length(ss)-1);
    js = char( zeros( 1, totlen ) );
    a = 1;
    b = length(ss{1});
    js(a:b) = ss{1};
    for i=2:length(ss)
        a = b+1;
        b = a+length(s)-1;
        js(a:b) = s;
        a = b+1;
        b = a+length(ss{i})-1;
        js(a:b) = ss{i};
    end
end
