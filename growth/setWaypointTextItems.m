function setWaypointTextItems( fig, state )
    hh = guidata(fig);
    set( hh.listbox_Waypoints, 'String', waypointDescriptions( state ) );
    if isempty( state.waypoints ) || (state.wpindex==0)
        set( hh.textThisSimTime, 'String', '' );
        set( hh.textThisFrames, 'String', '' );
        set( hh.textThisMovieTime, 'String', '' );
        set( hh.textTotalSimTime, 'String', num2str( 0 ) );
        set( hh.textTotalFrames, 'String', num2str( 0 ) );
        set( hh.textTotalMovieTime, 'String', num2str( 0 ) );
        set( hh.checkbox_crossfade, 'Value', 0 );
        set( hh.listbox_Waypoints, 'Value', [] );
    else
        state.wpindex = trimnumber( 1, state.wpindex, length(state.waypoints) );
        wp = state.waypoints(state.wpindex);
        if state.wpindex==1
            wpis = state.wpindex;
            thisFrames = 1;
        else
            wpis = [state.wpindex-1 state.wpindex];
            prevFrames = 1 + sum( [state.waypoints(1:(state.wpindex-1)).numframes] );
            thisFrames = [ prevFrames prevFrames+wp.numframes ];
        end
        thisSimTime = [ state.waypoints(wpis).simtime ];
        thisMovieTime = double(wp.numframes) / double(state.framerate);
        totalSimTime = state.waypoints(end).simtime;
        totalFrames = 1 + sum( [state.waypoints(:).numframes] );
        totalMovieTime = totalFrames / state.framerate;
        
        set( hh.textThisSimTime, 'String', twonums2str( thisSimTime ) );
        set( hh.textThisFrames, 'String', twonums2str( thisFrames ) );
        set( hh.textThisMovieTime, 'String', twonums2str( thisMovieTime ) );
        set( hh.textTotalSimTime, 'String', num2str( totalSimTime ) );
        set( hh.textTotalFrames, 'String', num2str( totalFrames ) );
        set( hh.textTotalMovieTime, 'String', num2str( totalMovieTime ) );
        set( hh.checkbox_crossfade, 'Value', wp.crossfade );
        set( hh.listbox_Waypoints, 'Value', state.wpindex );
    end
    set( hh.figure_waypoint, 'Userdata', state );
end

function ss = waypointDescriptions( state )
    ss = cell( 1, length(state.waypoints) );
    totalFrames = 1;
    for wpi=1:length(state.waypoints)
        wp_desc = num2str( wpi );
        wp = state.waypoints(wpi);
        if ~isempty(wp.name)
            wp_desc = [ wp_desc, ' ', wp.name ];
        end
        framebounds = totalFrames;
        simtimebounds = wp.simtime;
        if wpi > 1
            totalFrames = totalFrames + wp.numframes;
            framebounds = [framebounds, totalFrames];
            simtimebounds = [ state.waypoints(wpi-1).simtime simtimebounds ];
        end
        ss{wpi} = [ wp_desc ' frames ' twonums2str(framebounds) ...
                    ' simtime ' twonums2str( simtimebounds ) ];
    end
end
