function clickdragButtonUpFcn( hFigure, ~ )
    % Restore the original ButtonMotion and ButtonUp functions.
    % Invoke the finalisation callback to notify the host program that the
    % tracking has ended, so that it can read the camera info and update
    % host-specific data.
    % Finally, delete the trackball data.
    
    hObject = getUserdataField( hFigure, 'clickDragItem' );
    
    clickData = getClickData( hObject );
    
    if isempty(clickData), return; end
    
    hParent = get( hObject, 'Parent' );
    
    % Restore the old handlers.
    if isfield( clickData, 'oldWindowButtonMotionFcn' )
        set( hFigure, 'WindowButtonMotionFcn', clickData.oldWindowButtonMotionFcn );
    else
        set( hFigure, 'WindowButtonMotionFcn', '' );
    end
    if isfield( clickData, 'oldWindowButtonUpFcn' )
        set( hFigure, 'WindowButtonUpFcn', clickData.oldWindowButtonUpFcn );
    else
        set( hFigure, 'WindowButtonUpFcn', '' );
    end
    
    % Restore the old units.
    if isfield( clickData, 'olditemunits' )
        set( hObject, 'Units', clickData.olditemunits );
    end
    if isfield( clickData, 'oldfigureunits' )
        set( hFigure, 'Units', clickData.oldfigureunits );
    end
    if (hParent ~= hFigure) && isfield( clickData, 'oldparentunits' )
        set( hParent, 'Units', clickData.oldparentunits );
    end
    
    gd = guidata( hFigure );
    saveguidata = false;
    
    switch clickData.mousemode
        case { 'morpheditmodemenu:Add', 'morpheditmodemenu:Set', 'morpheditmodemenu:Fix' }
            updateBoxSelection( clickData );
            if isfield( clickData, 'boxselection' ) && ~isempty( clickData.boxselection ) && ishandle( clickData.boxselection )
                delete( clickData.boxselection );
                clickData.boxselection = [];
%                 saveguidata = true;
            end
        case { 'pan', 'zoom', 'rotate', 'rotupright' }
            if clickData.moved
                saveStaticPart( gd.mesh );
                gd.dragged = true;
                saveguidata = true;
            end
            clickData = trimStruct( clickData, ...
                { ...
                    'cameraLook', ...
                    'cameraUp', ...
                    'cameraRight', ...
                    'cameraTarget', ...
                    'cameraPosition', ...
                } );
        case 'dragitem'
            switch get( hObject, 'Tag' )
                case 'scalebar'
                    gd.mesh.plotdefaults.scalebarpos = relScaleBarPos( hObject.Position, hParent.Position([3 4]), [2 0 1 0] );
%                     fprintf( 1, 'cdBUF: Abs sb [%f %f %f %f], rel [%f %f], psize [%f %f]\n', ...
%                         hObject.Position, gd.mesh.plotdefaults.scalebarpos, hParent.Position([3 4]) );
                    saveguidata = true;
            end
               
            % If it's the scalebar, recalculate m.plotdefaults.scalebarpos.
            % Nothing to do.
%             fprintf( 1, 'B up\n' );
        otherwise
            fprintf( 1, '%s: unrecognised mousemode %s\n', mfilename(), clickData.mousemode );
    end

    setClickData( clickData, hObject );
    if saveguidata
        guidata( hFigure, gd );
    end
    deleteUserdataFields( hFigure, 'clickDragItem' );
    if isfield( gd, 'dragViewEnd_Callback' ) && ~isempty( gd.dragViewEnd_Callback )
        gd.dragViewEnd_Callback( hFigure );
    end
end

