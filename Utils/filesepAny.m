function f = filesepAny( computerType )
%f = filesepAny( computerType )
%   With no argument, this calls the built-in function filesep.
%   With an argument, if it begins with 'PC', then '\' is returned,
%   otherwise '/'. (This is the same test as filesep() performs, using the
%   result of computer() as the string to test.)
%
%   The purpose of this procedure is to construct file paths for a remote
%   machine of known type.

    if nargin < 1
        f = filesep();
    elseif strncmp(computerType,'PC',2)
        f = '\';
    else  % isunix
        f = '/';
    end
end
