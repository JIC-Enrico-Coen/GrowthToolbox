function isabs = isAbsolutePath( filename )
%isabs = isAbsolutePath( filename )
%   Determine whether a filename is absolute, i.e. proceeds form the root
%   of a file system.

   isabs =  ~isempty( regexp( filename, '^\\\\', 'once' ) ) ...
            || ~isempty( regexp( filename, '^[A-Z:\\', 'once' ) ) ...
            || ~isempty( regexp( filename, '^/', 'once' ) );
end