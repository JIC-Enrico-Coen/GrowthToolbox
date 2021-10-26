function fname = makefilename( fname )
%ifname = makefilename( modelname )
%   Turn an arbitrary string into something that can be a valid base file
%   name (without extension).
%   The string is mapped to lower case, and all non-alphanumerics are replaced
%   by underscore.

    fname = regexprep( lower(fname), '[^a-z0-9_]', '_' );
end
