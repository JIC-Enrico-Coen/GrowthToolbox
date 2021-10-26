function ifname = makeIFname( modelname )
%ifname = makeIFname( modelname )
%   Turn an arbitrary string into something that can be a valid Matlab
%   function name or struct field name.
%
%   The string is mapped to lower case, all non-alphanumerics are replaced
%   by underscore, and if the string does not begin with a letter, it is
%   prefixed by 'IF_'.

    ifname = regexprep( lower(modelname), '[^a-z0-9_]', '_' );
    if ~isempty(ifname)
        c = ifname(1);
        if (c < 'a') || (c > 'z')
            ifname = ['IF_' ifname];
        end
    end
end
