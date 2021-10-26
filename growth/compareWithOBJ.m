function result = compareWithOBJ( m, fn, varargin )
%result = compareWithOBJ( m, fn, varargin )
%   m is a mesh.  fn is the name of an OBJ file which is expected to
%   contain the node and triangle data for a mesh isomorphic to m.
%   The remaining arguments are strings naming the comparisons between the
%   mesh and the OBJ data that are to be returned.  Possibilities are:
%   'distance'    The distances between corresponding vertexes.
%   'area'  The ratios of areas of corresponding finite elements are
%           returned.
%   ...other possibilities may be added if needed.

    result = [];
    if isempty(varargin)
        return;
    end
    objdir = fullfile( m.globalProps.projectdir, m.globalProps.modelname, 'objs' );
    rm = readrawmesh( objdir, fn );
    if isempty(rm)
        fprintf( 1, 'compareWithOBJ could not read from %s in directory %s.\n', ...
            fn, objdir );
        beep;
        return;
    end
    for i=1:length(varargin)
        resulttypes.(varargin{i}) = 1;
    end
    if isfield( resulttypes, 'distance' )
        rmn = (rm.v(2:2:end,:) + rm.v(1:2:end,:))/2;
        result.distance = sqrt( sum( (m.nodes-rmn).^2, 2 ) );
    end
    if isfield( resulttypes, 'area' )
        rmn = (rm.v(2:2:end,:) + rm.v(1:2:end,:))/2;
        result.area = m.cellareas ./ findtriangleareas( rmn, m.tricellvxs ) - 1;
    end
end
