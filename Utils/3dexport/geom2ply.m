function ok = geom2ply( filename, geom, varargin )
%geom2ply( filename, geom, ... )
%   Write a geometry object to a file in PLY (Polygon File Format).
%   For information about PLY format, see
%   https://uk.mathworks.com/help/vision/ug/the-ply-format.html.
%   The properties currently output by this procedure are vertex positions and faces.
%   Other properties for which there are accepted conventions for representation in PLY format are:
%   vertex normal
%   vertex color
%   vertex transparency
%   face backside color (don't know how this is intended to be used)
%   edges
%   material properties uniform over the whole object.
%
%   Options:
%
%   modelname: A name for the object.  This will be included in a header comment.
%
%   username: The creator or generator of the object.  This will be included in a header comment.
%
%   split: A boolean, to indicate whether vertexes and edges should be split,
%       so that each face has its own vertexes and edges, not shared with any other face.
%       By default, this is equal to the facecolor option.
%
%   vertexcolor: A boolean (by default true) to specify whether vertex color data should be output, if present.
%
%   facecolor: A boolean (by default false) to specify whether face color data should be output,
%       if present.  This requires 'split' to be true.  Vertex color data and face color data cannot both be output; if both are requested, and present, vertex color will be written.

    fid = fopen( filename );
    ok = fid > 0;
    if ~ok
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'modelname', [], 'username', [] );
    [ok,s] = checkcommandargs( mfilename(), s, 'exact', ...
        'modelname', 'username' );
    if ~ok, return; end
    
    description = '';
    if ~isempty( s.modelname )
        description = [ description  ' model ''' s.modelname '''' ];
    end
    if ~isempty( s.username )
        description = [ description  ' created by ' s.username ];
    end
    if ~isempty(description)
        description = [ 'comment' description newline ];
    end

    fprintf( fid, ...
      [ 'ply', newline, ...
        'format ascii 1.0', newline, ...
        '%s', ...
        'element vertex %d', newline, ...
        'property float x', newline, ...
        'property float y', newline, ...
        'property float z', newline, ...
        'element face %d', newline, ...
        'property list uchar int vertex_indices', newline, ...
        'end_header', newline ], ...
        description, numvxs, numfaces );
    fprintf( fid, '%f %f %f\n', geom.vxs' );
        
    for i=1:numfaces
        fvxs = geom.facevxs(i,:);
        fvxs = fvxs(~isnan(fvxs));
        fprintf( fid, '%d\n', length(fvxs) );
        fprintf( fid, ' %f', fvxs );
        fwrite( fid, newline );
    end
    
    fclose( fid );
end
