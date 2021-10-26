function m = recordframe( m, frame )
    if ~movieInProgress(m)
        return;
    end
    if nargin < 2
        [m,ok,frame] = leaf_snapshot( m, '-', 'hires', m.plotdefaults.hiresmovies );
    end
    if ~ok || isempty( frame )
        return;
    end
    
    % If this frame is not the first, force it to be the same size as all
    % the previous frames.
%     framesize = size(frame);
%     framesize = framesize([1 2]);
    if ~isempty( m.globalProps.mov ) && ~isempty( m.globalProps.mov.Height )
        frame = trimframe( frame, ...
               [m.globalProps.mov.Height, m.globalProps.mov.Width], ...
                m.plotdefaults.bgcolor );
    end
    
    m=leaf_record_mesh_frame(m);
    try
        m.globalProps.mov = addmovieframe( m.globalProps.mov, frame );
        fprintf( 1, '%s: Recording movie frame at time %f, iteration %d.\n', ...
            datestring(), m.globalDynamicProps.currenttime, m.globalDynamicProps.currentIter );
        m.globalDynamicProps.framesinmovie = m.globalDynamicProps.framesinmovie + 1;
    catch e
        GFtboxAlert( 1, 'Could not add frame to movie.\n%s', ...
            e.message );
        try
            m.globalProps.mov = close( m.globalProps.mov );
        catch e %#ok<NASGU>
        end
        m.globalProps.mov = [];
    end
end
