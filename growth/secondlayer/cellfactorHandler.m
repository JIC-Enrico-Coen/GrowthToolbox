function cellfactorHandler()
    [hObject,tag,fig,handles,panelfig,panelhandles] = getGFtboxFigFromGuiObject();
    if isempty(hObject)
        return;
    end
    if isempty(handles.mesh)
        return;
    end
    if ~hasSecondLayer( handles.mesh )
        return;
    end
    cname = getMenuSelectedLabel( handles.displayedCellMgenMenu );
    ci = name2Index( handles.mesh.secondlayer.valuedict, cname );
    if ci==0
        return;
    end
    
%     fprintf( 1, '%s %s\n', mfilename(), tag );
    
    changed = false;
    
    switch tag
        case 'cfcolormode'
            modename = getMenuSelectedLabel( panelhandles.(tag) );
            modename = regexprep( lower(modename), '\W', '' );
            if ~isempty(modename)
                handles.mesh.secondlayer.cellcolorinfo(ci).mode = modename;
            	changed = true;
            end
        case 'cfrangeauto'
            handles.mesh.secondlayer.cellcolorinfo(ci).autorange = get( panelhandles.(tag), 'Value' );
            changed = true;
        case 'cfrangezero'
            handles.mesh.secondlayer.cellcolorinfo(ci).startfromzero = get( panelhandles.(tag), 'Value' );
            changed = true;
        case { 'cfrangemin', 'cfrangemax' }
            % Update m.secondlayer.cellcolorinfo(ci).range(1).
            [v1,ok1] = getDoubleFromString( 'cellular factor min', get( panelhandles.cfrangemin, 'String' ) );
            [v2,ok2] = getDoubleFromString( 'cellular factor max', get( panelhandles.cfrangemax, 'String' ) );
            if ok1 && ok2
                handles.mesh.secondlayer.cellcolorinfo(ci).range = [v1 v2];
                if handles.mesh.secondlayer.cellcolorinfo(ci).autorange
                    handles.mesh.secondlayer.cellcolorinfo(ci).autorange= false;
                    set( panelhandles.cfrangeauto, 'Value', 0 );
                end
                changed = true;
            end
        case 'setallcf'
            % Update all m.secondlayer.cellcolorinfo(:) from
            % m.secondlayer.cellcolorinfo(ci).
            if length(handles.mesh.secondlayer.cellcolorinfo) > 1
                handles.mesh.secondlayer.cellcolorinfo(:) = handles.mesh.secondlayer.cellcolorinfo(ci);
                changed = true;
            end
        case 'boundsfromcells'
            if ~isempty( handles.mesh.secondlayer.cellvalues )
                minval = min( handles.mesh.secondlayer.cellvalues(:,ci) );
                maxval = max( handles.mesh.secondlayer.cellvalues(:,ci) );
                setDoubleInTextItem( panelhandles.cfrangemin, minval );
                setDoubleInTextItem( panelhandles.cfrangemax, maxval );
            end
        otherwise
            return;
    end
    if changed
        guidata( fig, handles );
        if handles.mesh.plotdefaults.drawsecondlayer ...
                && hasNonemptySecondLayer( handles.mesh )
            notifyPlotChange( handles );
        end
    end
end
