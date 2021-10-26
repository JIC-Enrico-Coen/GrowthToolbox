function ie = iseof( line )
% ie = iseof( line )
%   Determines whether a value read from a file is signalling the end of
%   the file.

    ie = (length(line)==1) && isnumeric(line) && (line == -1);
end
