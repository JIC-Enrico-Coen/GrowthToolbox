function s = sprintAsIdentifier( varargin )
%s = sprintAsIdentifier( ... )
%   Apply sprintf() to the arguments, and in the result replace every
%   non-alphanumeric character by underscore.
%
%   The result will always be valid as a file name, provided it does not
%   exceed whatever length limit the operating system may impose.
%
%   It will be a valid Matlab variable name or field name if it begins with
%   a letter, and it will be a valid part of one if the whole begins with a
%   letter.
%
%   See also: string2Identifier

    s = sprintf( varargin{:} );
    s = string2Identifier( s );
end
