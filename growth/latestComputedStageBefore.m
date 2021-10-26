function [chosenStage,chosenTime,done] = latestComputedStageBefore( stagesMenu, stage, chosenStage, chosenTime )
    if nargin <= 2
        chosenStage = 'restart';
        chosenTime = 0;
    end
    done = false;
    curTime = stageStringToReal( stage );
    if isempty(curTime)
        % Invalid stage string.
        chosenStage = [];
        chosenTime = [];
        return;
    end
    c = get( stagesMenu, 'Children' );
    for i=length(c):-1:1
        t = get( c(i), 'Tag' );
        cc = get( c(i), 'Children' );
        if ~isempty(cc)
            [chosenStage,chosenTime,done] = latestComputedStageBefore( c(i), stage, chosenStage, chosenTime );
            if done
                return;
            end
            continue;
        end
        stage = stageTagToString( t );
        thisTime = stageStringToReal( stage );
        if isempty(thisTime)
            % Invalid stage string.
            continue;
        end
        if thisTime > curTime
            done = true;
            return;
        end
        l = get( c(i), 'Label' );
        stageexists = (~isempty(l)) && (l(1) ~= '(');  % ~isempty( regexp( l, '^(', 'once' ) );
        if stageexists
            chosenStage = stage;
            chosenTime = thisTime;
        end
    end
end

