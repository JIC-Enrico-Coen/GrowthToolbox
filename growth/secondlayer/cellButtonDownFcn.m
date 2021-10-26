function cellButtonDownFcn( hitObject, hitData, varargin )
    if ~ishghandle( hitObject )
        return;
    end
    ud = get( hitObject, 'Userdata' );
    if isempty(ud) || ~isfield( ud, 'biocell' )
        return;
    end
    [pt, bc, itemhit] = mySelect3d( hitObject, hitData );
    % The A side has itemhit in the range of 1:number of cells drawn on the
    % A side, and the B side numbering carries on from there.
    
    if isempty(itemhit)
        return;
    end
    
    handles = guidata( hitObject );
    if ~isfield( handles, 'mesh' ) || isempty(handles.mesh)
        return;
    end
    mm = getMouseModeFromGUI( handles );
    numcells = length( handles.mesh.secondlayer.cells );
    if numcells ~= length(ud.biocell)
        xxxx = 1;
    end
    if itemhit > numcells
        itemhit = itemhit - numcells;
    end
    switch mm
        case 'mouseCellModeMenu:Add cell'
            % NOT IMPLEMENTED
            % Get the point on the mesh where the hit was.
            % Get the current size of cell to create.
            % Create one cell. Ignore the overlap and off-edge settings.
%             cellvxs = handles.mesh.secondlayer.cells(itemhit).vxs;
%             cellFEs = handles.mesh.secondlayer.vxFEMcell(cellvxs);
%             [ ci, bc, bcerr, abserr, ishint ] = findFE( handles.mesh, pt, 'hint', cellFEs );
%             
%             [sides,ok1] = getIntFromDialog( handles.cellSidesText );
%             [relsize,ok2] = getDoubleFromDialog( handles.bioArelsizetext );
%             [axisratio,ok3] = getDoubleFromDialog( handles.bioAaxisratiotext );
%             [refinement,ok4] = getDoubleFromDialog( handles.bioArefinement );
%             if ok1 && ok2 && ok3 && ok4
%                 [c1,c2,cv] = bioAColorParams( handles );
%                 attemptCommand( handles, false, needReplot, ...
%                 	'makesecondlayer', ...
%                     'add', true, ...
%                     'mode', 'single', ...
%                     'positions', pt, ...
%                     'relarea', relsize, ...
%                     'axisratio', axisratio, ...
%                     'sides', sides, ...
%                     'refinement', refinement, ...
%                     'allowoverlap', get( handles.allowbiooverlapCheckbox, 'Value' ), ...
%                     'allowoveredge', get( handles.allowbiooveredgeCheckbox, 'Value' ), ...
%                     'colors', [c1;c2], 'colorvariation', cv );
%             end
%             guidata( hitObject, handles );
%             xxxx = 1;
        case 'mouseCellModeMenu:Delete cell'
             % NOT IMPLEMENTED
             % Get the index of the cell.
             % Delete that cell.
%              handles.mesh = leaf_deletebiocells( handles.mesh, 'cellstodelete', itemhit );
%              guidata( hitObject, handles );
%              ud = renumbersomehow( ud, itemhit );
%              set( hitObject, 'Userdata', ud );
             xxxx = 1;
   end
end
