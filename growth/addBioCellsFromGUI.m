function handles = addBioCellsFromGUI( handles, positions )
%addBioCellsFromGUI( handles, positions )
%   Add a round, isolated biological cell at each of the specified
%   positions.
%addBioCellsFromGUI( handles, n )
%   Add N round, isolated biological cells at random positions.

    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    
    if isempty(positions)
        return;
    end
    
    if numel(positions)==1
        numcells = positions;
        positions = [];
        if numcells==0
            return;
        end
    else
        numcells = size(positions,1);
    end
    if numcells==1
        mode = 'single';
    else
        mode = 'each';
    end
    
    [sides,ok1] = getIntFromDialog( handles.cellSidesText );
    [relsize,ok2] = getDoubleFromDialog( handles.bioArelsizetext );
    [axisratio,ok3] = getDoubleFromDialog( handles.bioAaxisratiotext );
    [refinement,ok4] = getDoubleFromDialog( handles.bioArefinement );
    if ok1 && ok2 && ok3 && ok4
        [c1,c2,cv] = bioAColorParams( handles );
        needReplot = handles.mesh.plotdefaults.drawsecondlayer;
        attemptCommand( handles, false, needReplot, ...
            'makesecondlayer', ...
            'mode', mode, ...
            'numcells', numcells, ...
            'positions', positions, ...
            'relarea', relsize, ...
            'axisratio', axisratio, ...
            'sides', sides, ...
            'refinement', refinement, ...
            'allowoverlap', get( handles.allowbiooverlapCheckbox, 'Value' ), ...
            'allowoveredge', get( handles.allowbiooveredgeCheckbox, 'Value' ), ...
            'colors', [c1;c2], 'colorvariation', cv );
    end
    setGFtboxHandles( handles );
end
