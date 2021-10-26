function js = joinNonemptyStrings( s, varargin )
%js = joinNonemptyStrings( s, ss )
%   ss is a cell array of strings.  Concatenate all non-empty members of ss
%   together, separated by the string s.

    if nargin < 2
        js = '';
        return;
    end

    if iscell( varargin{1} )
        ss = varargin{1};
    else
        ss = varargin;
    end
    
    ss = ss( ~strcmp( '', ss ) );
    js = joinstrings( s, ss );
end
