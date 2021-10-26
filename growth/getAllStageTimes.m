function [t,h] = getAllStageTimes( stagesmenu )
    [t,h] = getAllStageTimes1( stagesmenu );
    [t,p] = sort( t );
    h = h(p);
end

function [t,h] = getAllStageTimes1( stagesmenu )
    c = get( stagesmenu, 'Children' );
    if isempty(c)
        stagetag = get( stagesmenu, 'Tag' );
        stagestring = stageTagToString( stagetag );
        t = stageStringToReal( stagestring );
        h = stagesmenu;
    else
        tt = cell( 1, length(c) );
        hh = cell( 1, length(c) );
        len = 0;
        for i=1:length(c)
            [tt{i},hh{i}] = getAllStageTimes1( c(i) );
            len = len + length(tt{i});
        end
        t = zeros( 1,len );
        h = zeros( 1,len );
        start = 0;
        for i=1:length(c)
            n = length(tt{i});
            t( (start+1):(start+n) ) = tt{i};
            h( (start+1):(start+n) ) = hh{i};
            start = start + n;
        end
    end
end
