function cellroleHandler()
    global gCellRoleMenuDict

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
    rolemenulabel = getMenuSelectedLabel( panelhandles.cfroleMenu );
    [~,rolename] = value2Index( gCellRoleMenuDict, {rolemenulabel} );
    rolename = rolename{1};
        
    attemptCommand( handles, true, true, 'setcellfactorrole', ...
            rolename, ci );
end
