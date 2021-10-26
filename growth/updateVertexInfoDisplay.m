function h = updateVertexInfoDisplay( h, vi, mi )
%updateVertexInfoDisplay( h, vi, mi )
%   Update the display of morphogen value for a selected vertex.
%
%   h is the gui handles struct.
%
%   The second and thiurd arguments are optional. If absent, they default to
%   h.mesh.globalProps.displayedVertexIndex ) and
%   h.mesh.globalProps.displayedVertexMorphogen. If present, they are
%   assigned to those fields.

    if ~isstruct(h) || ~isfield( h, 'siminfoText' ) || ~ishghandle( h.siminfoText ) ||  ~isGFtboxMesh( h.mesh )
        return;
    end
    changed = false;
    if (nargin >= 2) && ~isempty( vi )
        if isempty(h.mesh.globalProps.displayedVertexIndex) || (h.mesh.globalProps.displayedVertexIndex ~= vi)
            changed = true;
            h.mesh.globalProps.displayedVertexIndex = vi;
        end
    end
    if (nargin >= 3) && ~isempty( mi )
        if isempty(h.mesh.globalProps.displayedVertexMorphogen) || (h.mesh.globalProps.displayedVertexMorphogen ~= mi)
            changed = true;
            h.mesh.globalProps.displayedVertexMorphogen = mi;
        end
    else
%         h.mesh.globalProps.displayedVertexMorphogen = getDisplayedMgenIndex( getGFtboxHandles() )
    end
    haveInfo = ~isempty( h.mesh.globalProps.displayedVertexIndex ) && ~isempty( h.mesh.globalProps.displayedVertexMorphogen );
    if haveInfo
        mgenIndex = FindMorphogenIndex( h.mesh, h.mesh.globalProps.displayedVertexMorphogen );
        vx = h.mesh.globalProps.displayedVertexIndex(1);
        haveInfo = ~isempty(mgenIndex) && (mgenIndex(1) ~= 0) && (vx > 0) && (vx <= getNumberOfVertexes(h.mesh));
    end
    if haveInfo
        mgenName = FindMorphogenName( h.mesh, mgenIndex(1) );
        set( h.siminfoText, 'String', ...
             sprintf( 'Vx %d: %s = %.3g', ...
                 vx, ...
                 mgenName{1}, ...
                 h.mesh.morphogens( vx, mgenIndex(1) ) ) );
    else
        h.mesh.globalProps.displayedVertexIndex = [];
        h.mesh.globalProps.displayedVertexMorphogen = [];
        set( h.siminfoText, 'String', '' );
    end
    if changed
        guidata(h.GFTwindow, h);
    end
end 
