function simpleExceptionMessage( e )
    if nargin < 1
        e = lasterror;
    end
    beep;
    fprintf( 1, '    %s\n    %s\n    Function %s\n    in file %s\n    at line %d\n', ...
        e.identifier, e.message, ...
        e.stack(1).name, ...
        e.stack(1).file, ...
        e.stack(1).line );
    dbstack;
end
