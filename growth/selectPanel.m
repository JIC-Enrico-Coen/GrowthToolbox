function selectPanel( handles, panelname )
    panelnames = fieldnames(handles.panels);
    for i=1:length(panelnames)
        if ~strcmp(panelnames{i},panelname)
            pname = strcat( panelnames{i}, 'panel' );
            if get( handles.(pname), 'Visible' );
                set( handles.(pname), 'Visible', 'off' );
            end
        end
    end
    
    % Set the interaction mode based on the panel?
    
    
    drawnow;
    pname = strcat( panelname, 'panel' );
    set( handles.(pname), 'Visible', 'on' );
    % Force redraw -- some machines don't redraw the controls.
    if true || (isfield( handles, 'aggressiveRedraw' ) && handles.aggressiveRedraw)
        drawnow;
    end
end
