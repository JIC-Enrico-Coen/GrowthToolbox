function s = string2Identifier( s )
%s = string2Identifier( ... )
%   Convert an arbitrary string into a form that can be validly used as a
%   file name, variable name, or field name. This is done by replacing
%   every non-alphanumeric character by underscore.
%
%   The result will always be valid as a file name, provided it does not
%   exceed whatever length limit the operating system may impose.
%
%   It will be a valid Matlab variable name or field name if it begins with
%   a letter, and it will be a valid part of one if the whole begins with a
%   letter.
%
%   See also: sprintAsIdentifier

    s = regexprep( s, '\W', '_' );
end
