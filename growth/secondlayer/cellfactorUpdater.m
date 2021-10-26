function cellfactorUpdater( hObject )
%cellfactorUpdater( hObject )
%   Update the cell factors panel from the mesh.
    ph = getFloatingPanel( hObject, 'cellmgens' );
    if isempty( ph )
        return;
    end
    [~,~,~,h,~,panelhandles] = getGFtboxFigFromGuiObject( ph );
    if isempty(panelhandles)
        return;
    end
    
    if hasSecondLayer( h.mesh )
        cname = getMenuSelectedLabel( h.displayedCellMgenMenu );
        ci = name2Index( h.mesh.secondlayer.valuedict, cname );
        haveFactor = ci > 0;
    else
        haveFactor = false;
    end
    
    global gSecondLayerColorInfo gCellRoleMenuDict
    
    if haveFactor
        cfvalues = h.mesh.secondlayer.cellcolorinfo(ci);
    else
        cfvalues = gSecondLayerColorInfo;
    end
    if numel(cfvalues.edgecolor)==1
        cfvalues.edgecolor = cfvalues.edgecolor + [0 0 0];
    end
    
    set( panelhandles.cfrangeauto, 'Value', cfvalues.autorange );
    set( panelhandles.cfrangezero, 'Value', cfvalues.issplit );
    if isempty( cfvalues.range )
        cfvalues.range = [0 1];
    end
    setDoubleInTextItem( panelhandles.cfrangemin, cfvalues.range(1) );
    setDoubleInTextItem( panelhandles.cfrangemax, cfvalues.range(2) );
    setMenuSelectedLabel( panelhandles.cfcolormode, cfvalues.mode );
    set( panelhandles.poscolorchooser, 'BackgroundColor', cfvalues.pos );
    set( panelhandles.negcolorchooser, 'BackgroundColor', cfvalues.neg );
    set( panelhandles.edgecolorchooser, 'BackgroundColor', cfvalues.edgecolor );
    menumodes = get( panelhandles.cfcolormode, 'String' );
    for i=1:length(menumodes)
        m = regexprep( lower(menumodes{i}), '\W', '' );
        if strcmp( cfvalues.mode, m )
            set( panelhandles.cfcolormode, 'Value', i );
            break;
        end
    end
    
    % Set the role menu to the role of the current factor.
    if hasSecondLayer( h.mesh )
        [~,rolecode] = value2Index( h.mesh.secondlayer.cellfactorroles, ci );
        rolecode = rolecode{1};
        if isempty(rolecode)
            set( panelhandles.cfroleMenu, 'Value', 1 );
        else
            [~,rolename] = name2Index( gCellRoleMenuDict, rolecode );
            rolename = rolename{1};
            setMenuSelectedLabel( panelhandles.cfroleMenu, rolename );
        end
    else
        set( panelhandles.cfroleMenu, 'Value', 1 );
    end
end
