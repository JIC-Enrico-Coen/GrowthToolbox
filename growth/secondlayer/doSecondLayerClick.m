function doSecondLayerClick( varargin )
    if nargin < 1, return; end
    hitObject = varargin{1};
    parent = get( hitObject, 'Parent' );
    ud = get( hitObject, 'UserData' );
    theaxes = ancestor(hitObject,'axes');
    hitPoint3D = get(theaxes,'CurrentPoint');
    doSecondLayerClick_n = getPatchHit( hitObject, hitPoint3D );
    if doSecondLayerClick_n==0
        return;
    end
    
    handles = guidata( hitObject );
    
    mousemode = getMouseModeFromGUI( handles );

    if isstruct( ud ) && isfield( ud, 'biocell' )
        handles = guidata( hitObject );
        ci = doSecondLayerClick_n;
        numcells = length(handles.mesh.secondlayer.cloneindex);
        if ci > numcells
            ci = ci - numcells;
        end
        fprintf( 1, 'Click on second layer cell %d, area %e.\n', ...
            ci, handles.mesh.secondlayer.cellarea(ci) );
        2
        isShocked = handles.mesh.secondlayer.cloneindex( ci ) > 1;
        if isShocked
            fprintf( 1, 'doSLC: was shocked: %d\n', handles.mesh.secondlayer.cloneindex( ci ) );
            colorindex = 1;
            handles.mesh.secondlayer.cloneindex( ci ) = 1;
        else
            fprintf( 1, 'doSLC: was not shocked: %d\n', handles.mesh.secondlayer.cloneindex( ci ) );
            colorindex = 2;
            handles.mesh.secondlayer.cloneindex( ci ) = 2;
        end
        if ~isempty( handles.mesh.secondlayer.cellcolor )
            handles.mesh.secondlayer.cellcolor(ci,:) = ...
                secondlayercolor( 1, ...
                    handles.mesh.globalProps.colorparams(colorindex,:) );
            cdata = get( hitObject, 'CData' );
            cdata( ci, :, : ) = handles.mesh.secondlayer.cellcolor(ci,:);
            ci1 = ci + numcells;
            if ci1 <= size( cdata, 1 )
                cdata( ci1, :, : ) = handles.mesh.secondlayer.cellcolor(ci,:);
            end
            set( hitObject, 'CData', cdata );
        end
        guidata( parent, handles );
    end
end

