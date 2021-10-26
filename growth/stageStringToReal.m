function t = stageStringToReal( stagestring )
%t = stageStringToReal( stagestring )
%   Convert a stage string as used within the filename of a stage file into
%   a numerical time.  The string is assumed to not include the '_s' prefix.
%
%   See also: stageTimeToText.

global gMISC_GLOBALS;

    if isempty( stagestring )
        t = [];
    elseif strcmp( stagestring, 'restart' )
        t = 0;
    elseif regexp( stagestring, ['^' gMISC_GLOBALS.stageregexp '$'] )
        s = regexprep( stagestring, '[mM]', '-' );
        s = regexprep( s, '[dD]', '.' );
        t = sscanf( s, '%f' );
    else
        fprintf( 1, 'Unparseable stage string "%s".\n', stagestring );
        t = [];
    end
end

