function callbackWaypoints()
    hObject = gcbo();
    callbackWaypoints_Tag = get( hObject, 'Tag' );
    hh = guidata( hObject );
    state = get( hh.figure_waypoint, 'Userdata' );
    
    switch callbackWaypoints_Tag
        case 'editName'
            state.waypoints(state.wpindex).name = ...
                get( hh.(callbackWaypoints_Tag), 'String' );
            setWaypointTextItems( hh.figure_waypoint, state );
        case 'editFrames'
            [x,ok] = getDoubleFromDialog( hObject );
            if ok
                updateUserdata( hh.figure_waypoint, round(x), [], [], [], [], [] );
            end
        case 'editMovieDuration'
            [x,ok] = getDoubleFromDialog( hh.(callbackWaypoints_Tag) );
            if ok
                updateUserdata( hh.figure_waypoint, [], x, [], [], [], [] );
            end
        case 'editSimDuration'
            [x,ok] = getDoubleFromDialog( hh.(callbackWaypoints_Tag) );
            if ok
                updateUserdata( hh.figure_waypoint, [], [], x, [], [], [] );
            end
        case 'editTimestep'
            [x,ok] = getDoubleFromDialog( hh.(callbackWaypoints_Tag) );
            if ok
                updateUserdata( hh.figure_waypoint, [], [], [], x, [], [] );
            end
        case 'editFramerate'
            [x,ok] = getDoubleFromDialog( hh.(callbackWaypoints_Tag) );
            if ok
                state.framerate = x;
                % Update real times.
            end
        case 'edit_Spins'
            [x,ok] = getDoubleFromDialog( hh.(callbackWaypoints_Tag) );
            if ok
                updateUserdata( hh.figure_waypoint, [], [], [], [], round(x), [] );
            end
        case 'edit_Tilts'
            [x,ok] = getDoubleFromDialog( hh.(callbackWaypoints_Tag) );
            if ok
                updateUserdata( hh.figure_waypoint, [], [], [], [], [], round(x) );
            end
        case 'edit_TiltAngle'
            [x,ok] = getDoubleFromDialog( hh.(callbackWaypoints_Tag) );
            if ok
                state.waypoints(state.wpindex).crossfade = x;
                set( hh.figure_waypoint, 'Userdata', state );
            end
        case 'checkbox_crossfade'
            state.waypoints(state.wpindex).crossfade = ...
                get( hh.(callbackWaypoints_Tag), 'Value' );
            set( hh.figure_waypoint, 'Userdata', state );
        case 'pushbutton_delete_waypoint'
            if state.wpindex == 1
                queryDialog( 1, 'Not allowed', 'The first waypoint cannot be deleted.' );
            else
                state.waypoints = state.waypoints([1:(state.wpindex-1) (state.wpindex+1):end]);
                if state.wpindex > length(state.waypoints)
                    state.wpindex = length(state.waypoints);
                end
                loadWaypointIntoDialog( hh, state );
            end
        case 'listbox_Waypoints'
            wpi = get( hh.(callbackWaypoints_Tag), 'Value' );
            if isempty(wpi)
                set( hh.(callbackWaypoints_Tag), 'Value', state.wpindex );
            else
                state.wpindex = wpi;
                loadWaypointIntoDialog( hh, state );
            end
            set( hh.figure_waypoint, 'Userdata', state );
        case 'pushbutton_make_movie'
            fprintf( 1, '%s: unimplemented %s.\n', mfilename(), callbackWaypoints_Tag );
            % ********
            % [m,ok] = leaf_waypointmovie( m );
        case 'pushbutton_make_script'
            fprintf( 1, '%s: unimplemented %s.\n', mfilename(), callbackWaypoints_Tag );
            % ********
        case 'radiobutton_all_waypoints'
            fprintf( 1, '%s: unimplemented %s.\n', mfilename(), callbackWaypoints_Tag );
            % No action.
        case 'radiobutton_selected_waypoints'
            fprintf( 1, '%s: unimplemented %s.\n', mfilename(), callbackWaypoints_Tag );
            % No action.
        case 'pushbutton_save'
            fprintf( 1, '%s: unimplemented %s.\n', mfilename(), callbackWaypoints_Tag );
            % ********
        case 'pushbutton_revert'
            fprintf( 1, '%s: unimplemented %s.\n', mfilename(), callbackWaypoints_Tag );
            % ********
        case 'pushbutton_close'
            fprintf( 1, '%s: unimplemented %s.\n', mfilename(), callbackWaypoints_Tag );
            % ********
        otherwise
            fprintf( 1, '%s: unexpected tag %s.\n', mfilename(), callbackWaypoints_Tag );
    end
end

function loadWaypointIntoDialog( hh, state )
    % ********
    if state.wpindex==0
        set( hh.editName, 'String', '' );
        set( hh.editFrames, 'String', '' );
        set( hh.editSimDuration, 'String', '' );
        set( hh.editMovieDuration, 'String', '' );
        set( hh.editTimestep, 'String', '' );
        set( hh.editFramerate, 'String', '' );
        set( hh.edit_FPG, 'String', '' );
        set( hh.edit_Spins, 'String', '' );
        set( hh.edit_Tilts, 'String', '' );
        set( hh.edit_TiltAngle, 'String', '' );
        set( hh.checkbox_crossfade, 'Value', false );
    else
        wp = state.waypoints(state.wpindex);
        set( hh.editName, 'String', wp.name );
        set( hh.editFrames, 'String', num2str( wp.numframes ) );
        set( hh.editSimDuration, 'String', num2str( wp.numframes * wp.timestep ) );
        set( hh.editMovieDuration, 'String', num2str( wp.numframes / state.framerate ) );
        set( hh.editTimestep, 'String', wp.timestep );
        set( hh.editFramerate, 'String', state.framerate );
        set( hh.edit_FPG, 'String', wp.framespergyration );
        set( hh.edit_Spins, 'String', wp.spins );
        set( hh.edit_Tilts, 'String', wp.tilts );
        set( hh.edit_TiltAngle, 'String', wp.tiltangle );
        set( hh.edit_TiltAngle, 'String', wp.tiltangle );
        set( hh.checkbox_crossfade, 'Value', wp.crossfade );
    end
    setWaypointTextItems( hh.figure_waypoint, state );
end

function updateUserdata( h, ...
                      newframes, newrealduration, newsimduration, ...
                      newtimestep, newspins, newtilts )
    state = get( h, 'Userdata' );
    if state.wpindex==0
        state.waypoints = emptyWaypoint();
        state.wpindex = 1;
    end
    wpi = state.wpindex;
    wp = state.waypoints(wpi);
    if wpi == 1
        wp_prev = [];
    else
        wp_prev = state.waypoints(wpi-1);
    end
    if ~isempty(newframes)
        if wpi==1
            % Ignore.
        else
            wp.numframes = newframes;
            wp.simtime = wp_prev.simtime + newframes * wp.timestep;
        end
    elseif ~isempty(newrealduration)
        if wpi==1
            % Ignore.
        else
            if state.framerate > 0
                wp.numframes = round( newrealduration * state.framerate );
            end
            wp.simtime = wp.numframes * wp.timestep;
        end
    elseif ~isempty(newsimduration)
        if wpi==1
            % Ignore.
        else
            if wp.timestep > 0
                wp.numframes = round( newsimduration / wp.timestep );
            end
            if wp.numframes > 0
                wp.timestep = newsimduration / wp.numframes;
            end
            delta_t = newsimduration - (wp.simtime - wp_prev.simtime);
            wp.simtime = wp.simtime + delta_t;
            for i=wpi+1:length(state.waypoints)
                state.waypoints(i).simtime = state.waypoints(i).simtime + delta_t;
            end
        end
    elseif ~isempty(newtimestep)
        if wpi==1
            % Ignore.
        else
            wp.timestep = newtimestep;
            if wp.timestep > 0
                wp.numframes = round( wp.simtime / wp.timestep );
            end
            if wp.numframes > 0
                wp.timestep = wp.simtime / wp.numframes;
            end
            delta_t = newsimduration - (wp.simtime - wp_prev.simtime);
            for i=wpi:length(state.waypoints)
                state.waypoints(i).simtime = state.waypoints(i).simtime + delta_t;
            end
        end
    elseif ~isempty(newspins) || ~isempty(newtilts)
        if wpi==1
            % Ignore.
        else
            oldgyrations = max( wp.spins, wp.tilts );
            if ~isempty(newspins)
                wp.spins = newspins;
            end
            if ~isempty(newtilts)
                wp.tilts = newtilts;
            end
            newgyrations = max(wp.spins,wp.tilts);
            if (oldgyrations ~= newgyrations) && (wp.simtime == wp_prev.simtime)
                wp.numframes = wp.framespergyration * newgyrations;
            end
        end
    end
    state.waypoints(wpi) = wp;
    loadWaypointIntoDialog( guidata(h), state );
end
