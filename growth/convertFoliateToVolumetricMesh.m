function m = convertFoliateToVolumetricMesh( m, varargin )
%m = convertFoliateToVolumetricMesh( m, ... )
%   Convert a sheet of pentahedra into a volumetric mesh of tetrahedra.
%
%   Options:
%
%   dissection:  How to dissect a single pentahedron.  Possibilities are:
%       none:  Use pentahedra as the volumetric elements.
%       minimal:  Dissect each pentahedron into three tetrahedra.
%       symmetric (the default):  Dissect each pentahedron into fourteen
%           tetrahedra.
%
%   layers:  (Default 1.) How many layers of pentahedra to divide each
%       pentahedron into, before converting to tetrahedra.
%
%   heightmgen:  (Default 'V_HEIGHT'.) The name of a morphogen, or the
%       index of an existing one, to use as an indication of the position
%       of each vertex in the normal direction. It is set to 0 for vertexes
%       on the A side, 1 for the B side, and a proportional value for
%       vertexes in between. If a name is given, the morphogen will be
%       created if it does not already exist.
%
%   WORK IN PROGRESS.

    if isVolumetricMesh( m )
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'dissection', [], 'layers', 1, 'heightmgen', 'V_HEIGHT' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'dissection', 'layers', 'heightmgen' );
    if ~ok, return; end
    
    % THIS MAKES NO SENSE.
    % If the condition is true, the morphogen already exists, and adding it
    % has no effect.
    if FindMorphogenIndex( m, s.heightmgen )
        m = leaf_add_mgen( m, s.heightmgen );
    end
    
    vxs = m.prismnodes;
    dims = 3;
    % Divide each pentahedron into a stack of pentahedra.
    if s.layers > 1
    else
        vxs = m.prismnodes;
        
    end
    
    % Divide each pentahedron into tetrahedra, according to the dissection
    % type.
    
    switch s.dissection
        case 'none'
            % Convert the mesh to a volumetric mesh of pentahedra.
        case 'minimal'
            % Find a consistent decomposition of all the pentahedra.
        case 'symmetric'
            % Add a new vertex at the centre of every quadrangular face and
            % the centre of every pentahedron.
            
            pentacentres = (sum( reshape( m.nodes( m.tricellvxs', : ), 3, getNumberOfFEs(m), dims ), 3 )/dims)';
            facecentres = sum( reshape( m.nodes( m.edgeends', : ), 2, getNumberOfEdges(m), dims ), 3 )/dims;
            
            allvxs = [ vxs; facecentres; pentacentres ];
            numorigvxs = size( vxs, 1 );
            numfacecentres = size( facecentres, 1 );
            numpentacentres = size( pentacentres, 1 );
            numpentahedra = getNumberOfFEs( m );
            facecentreoffset = numorigvxs;
            pentacentreoffset = numorigvxs + numfacecentres;
            
            % For each pentahedron, find the indexes in allvxs of its face and volume
            % centres.
            pentafacevxs = m.celledges + facecentreoffset;
            pentacentrevxs = (1:numpentahedra)' + pentacentreoffset;
            pentaextendedvxs = [ vxs, pentafacevxs, pentacentrevxs ];
            subtetras = [ 10 1 2 3
                          10 4 6 5
                          10 7 2 3
                          10 7 3 6
                          10 7 6 5
                          10 7 5 2
                          10 8 3 1
                          10 8 1 4
                          10 8 4 6
                          10 8 6 3
                          10 9 1 2
                          10 9 2 5
                          10 9 5 4
                          10 9 4 1 ];
            subtetras(:,1) = subtetras(:,1) + pentacentreoffset;
            subtetras(3:end,2) = subtetras(3:end,2) + facecentreoffset;
            strides = zeros(size(subtetras));
            strides(:,1) = 1;
            strides(3:end,2) = 3;
            
            tetrasperpenta = size(subtetras,1);
            newfevxs = zeros( size(subtetras,1)*numpentacentres, 4 );
            for i=1:numpentacentres
                newfevxs( (tetrasperpenta*i+1):(tetrasperpenta*(i+1)), : ) = subtetras + strides*i;
            end
        otherwise
            error
    end
    
    % Need extra built-in morphogen to mark distance through the mesh.
    % 
end
