function t = stageTimeFromFilename( f )
    global gMISC_GLOBALS

    [~,basename,~] = fileparts(f);
    t = [];
    s = regexp( basename, [ '^[A-Za-z0-9_ ]+', gMISC_GLOBALS.stageprefix, '(?<time>[0-9DdMm]+)$' ], 'names' );
    if isempty(s)
        return;
    end
    t = stageStringToReal( s.time );
end