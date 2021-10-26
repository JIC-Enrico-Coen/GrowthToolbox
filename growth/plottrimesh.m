function plottrimesh( varargin )
%plottrimesh( ... )
%   Simple plot of a mesh.
%
%   plottrimesh(FILENAME) will read the obj file FILENAME and plot it in
%   the current figure.
%
%   plottrimesh( V, F ) will plot the triangles specified by V and F.  V is
%   an N*3 array of vertexes and F is an M*3 array of vertex indexes.
%
%   plottrimesh(R), where R has fields V and F will plot R.V and R.F.
%
%   plottrimesh(M), where M has fields NODES and TRICELLVXS will plot
%   M.NODES and M.TRICELLVXS.

    if nargin==0, return; end
    if nargin==1
        if ischar( varargin{1} )
            formats = struct( 'f', '%d' );
            r = addToRawMesh( [], varargin{1}, formats );
            v = r.v;
            f = r.f;
        else
            r = varargin{1};
            if isfield( r, 'v' )
                v = r.v;
                f = r.f;
            else
                v = r.nodes;
                f = r.tricellvxs;
            end
        end
    else
        v = varargin{1};
        f = varargin{2};
    end
    x = reshape( v(f',1), 3, [] );
    y = reshape( v(f',2), 3, [] );
    z = reshape( v(f',3), 3, [] );
    fill3( x, y, z, 'c' );
end
