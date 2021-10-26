function [m,errmsg] = msrToMesh( msr, saveExtra )
    if nargin < 2
        saveExtra = true;
    end
    m = [];
    errmsg = '';
    if isempty(msr) || ~isfield( msr, 'OBJECT' ) || isempty( msr.OBJECT )
        errmsg = 'No mesh data found.';
        return;
    end
    o = msr.OBJECT{1};
    if ~isfield( o, 'VERT' )
        errmsg = 'No VERT data.';
        return;
    end
    if ~isfield( o, 'FACE' )
        errmsg = 'No FACE data.';
        return;
    end
    m.nodes = o.VERT; %  .* repmat( o.SCALE, size(o.VERT,1), 1 );
    m.tricellvxs = o.FACE;
    m = setmeshfromnodes( m );
    if saveExtra
        m.userdata.msrdata = safermfield( o, ...
            'VERT', 'VERTCOUNT', ...
            'EDGE', 'EDGECOUNT', ...
            'FACE', 'FACECOUNT' );
        m.userdata.msrmetadata = safermfield( msr, 'OBJECT' );
    else
        m.userdata.msrdata = [];
        m.userdata.msrmetadata = [];
    end
end
