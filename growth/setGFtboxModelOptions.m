function m = setGFtboxModelOptions( varargin )
%m = setGFtboxModelOptions( optionname1, value1, optionname2, value2, ... )
%   Like setModelOptions, but operates on the mesh currently loaded into
%   GFtbox. If there is no such mesh, does nothing. The modified mesh is
%   returned.

    m1 = getGFtboxMesh();
    if ~isempty(m1)
        m1 = setModelOptions( m1, varargin{:} );
        setGFtboxMesh( m1 );
    end
    if nargout > 0
        m = m1;
    end
end