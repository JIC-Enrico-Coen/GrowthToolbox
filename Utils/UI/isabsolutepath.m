function isabs = isabsolutepath( filename )
%isabs = isabsolutepath( filename )
%   Determine whether the filename is an absolute pathname or not.
%   It is deemed to be absolute if it begins with a slash, a backslash, or
%   /[A-Za-z]:/.

    isabs = (~isempty(regexp( filename, '^[A-Za-z]:' ))) ...
         || (~isempty(regexp( filename, '^[\\/]' )));
end
