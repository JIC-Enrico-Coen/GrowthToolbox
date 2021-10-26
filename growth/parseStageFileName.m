function [basename,stagestring,stagetime] = parseStageFileName( sfn )
% Take a file name, with or without .mat extension, and with or without a
% directory path, and look for a stage file suffix. If there is none,
% return basename as the original name unchanged, stagestring
% as empty, and stagetime as zero.  Otherwise, return the basename as
% everything before the stage suffix, the stage segment as the stage suffix
% without the leading '_s', and the corresponding
% real number in stagetime.  If the suffix fails to parse as a number,
% return stagestring as -1 and stagetime as zero.

    global gMISC_GLOBALS
    tokens = regexp( sfn, ['^(.*)', gMISC_GLOBALS.stageprefix, '([mM]?[0-9]+([dD][0-9]+)?)(.[Mm][Aa][Tt])?$'], 'tokens' );
    if (length(tokens)==1) && (length(tokens{1})>=2)
        basename = tokens{1}{1};
        numstring = tokens{1}{2};
        stagetime = stageStringToReal( numstring );
        if isempty(stagetime)
            stagestring = -1;
            stagetime = 0;
        else
            stagestring = [gMISC_GLOBALS.stageprefix, numstring];
            numstring = regexprep( numstring, '[mM]', '-' );
            numstring = regexprep( numstring, '[dD]', '.' );
            [stagetime,count] = sscanf( numstring, '%f', 1 );
        end
    else
        basename = sfn;
        stagestring = -1;
        stagetime = 0;
    end
end
