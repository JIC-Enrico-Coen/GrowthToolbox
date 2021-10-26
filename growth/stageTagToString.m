function stage = stageTagToString( t )
    global gMISC_GLOBALS
    if regexp(t,'^itemStage')
        if strcmp(t,'itemStage_initial')
            stage = 'restart';
        else
            stage = regexprep( t, ['^itemStage',gMISC_GLOBALS.stageprefix], '' );
        end
    else
        stage = '';
    end
end