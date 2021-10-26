function tag = normaliseTag( tag )
%tag = normaliseTag( tag )
%   Take a string from which a GUI object tag is to be made, and normalise
%   it by:
%   * Converting to lower case.
%   * Deleting everything other than lower case letters, numbers,
%     underscore, and spaces.
%   * Deleting leading and trailing spaces.
%   * Replacing all remaining spaces by underscores.
%
%   If tag is a cell array, each member will be normalised.

    if iscell(tag)
        for i=1:length(tag)
            tag{i} = normaliseTag( tag{i} );
        end
    else
        tag = regexprep( tag, '[^a-z0-9_\s]', '' );
        tag = regexprep( tag, '^\s+', '' );
        tag = regexprep( tag, '\s+$', '' );
        tag = regexprep( tag, '\s+', '_' );
    end
end
