function m = rotatemesh( m, rotmatrix, euleraxes )
%m = rotatemesh( m, rotmatrix, euleraxes )
%    Rotate the mesh about the origin by the given matrix.
%    If ROTMATRIX is a 3*3 matrix, EULERAXES is ignored.  
%    If ROTMATRIX is a vector of one, two, or three numbers, it is
%    interpreted as a set of Euler angles, about axes specified by
%    EULERAXES.  EULERAXES is a string of characters of the same length as
%    rotmatrix, consisting of 'X', 'Y', or 'Z'.
fprintf( 1, 'rotatemesh\n' );
    if numel(rotmatrix) <= 3
        rotmatrix = eulerRotation( rotmatrix, euleraxes );
    end
    
    isVol = isVolumetricMesh(m);

    if isVol
        m.FEnodes = m.FEnodes * rotmatrix';
    else
        m.nodes = m.nodes * rotmatrix';
        m.prismnodes = m.prismnodes * rotmatrix';
        m.unitcellnormals = m.unitcellnormals * rotmatrix';
    end
    m.gradpolgrowth = m.gradpolgrowth * rotmatrix';
    if isfield( m, 'gradpolgrowth2' )
        m.gradpolgrowth2 = m.gradpolgrowth2 * rotmatrix';
    end
    if ~isempty(m.displacements)
        m.displacements = m.displacements * rotmatrix';
    end
    m.secondlayer.cell3dcoords = m.secondlayer.cell3dcoords * rotmatrix';
    
    m = rotateAllTensors( m, rotmatrix );
end

