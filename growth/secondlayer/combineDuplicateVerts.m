function varargout = combineDuplicateVerts( varargin )
%sl = combineDuplicateVerts( sl, tol )
%   sl is a structure with fields pts and cellvxs.  sl.pts is an N*D array
%   representing N points in D-dimensional space.  sl.cellvxs is an
%   array, each row of which is a list of indexes into the first dimension
%   of sl.pts, possibly padded with zeros.
%
%   This finds all pairs of points closer than tol (default 1e-6) times the
%   maximum diameter of the bounding box of sl.pts, and amalgamates them,
%   reindexing sl.cellvxs as necessary.  It also deletes all points not
%   referenced by sl.cellvxs
%
%[pts, cellvxs] = combineDuplicateVerts( pts, cellvxs, tol )
%   Similar to the first method, but with pts and cellvxs supplied and
%   returned separately.
%
%m = combineDuplicateVerts( m, tol )
%   The same operation is done to the cellular layer of the GFtbox mesh m.

    m = [];
    tol = [];
    if isGFtboxMesh( varargin{1} )
        m = varargin{1};
        if ~hasNonemptySecondLayer( m )
            return;
        end
        sl = struct( 'pts', m.secondlayer.cell3dcoords );
        sl.cellvxs = { m.secondlayer.cells.vxs };
        argsused = 1;
        calltype = 'm';
    elseif isstruct( varargin{1} ) && isfield(varargin{1},'pts') && isfield(varargin{1},'cellvxs')
        sl = varargin{1};
        argsused = 1;
        calltype = 's';
    else
        sl = struct( 'pts', varargin{1}, 'cellvxs', varargin{2} );
        argsused = 2;
        calltype = 'p';
    end
    if nargin > argsused
        tol = varargin{argsused+1};
    end
    if isempty(sl)
        return;
    end
    if isnan(tol)
        return;
    end
    if isempty(tol)
        tol = 1e-6;
    end
    diam = max( max(sl.pts,[],1) - min(sl.pts,[],1) );
    tol = tol*diam;
    ndims = size(sl.pts,2);
    clumpindex = zeros(size(sl.pts));
    for i=1:ndims
        [v,perm] = sort( sl.pts(:,i) );
        vdiff = [ true; abs( v(1:(end-1)) - v(2:end) ) > tol ];
        clumpindex(perm,i) = cumsum( vdiff );
    end
    % Two rows of clumpindex are identical whenever the corresponding
    % points agree in all their coordinates to within the tolerance.
    
    [~,ia,ic] = unique( clumpindex, 'rows', 'stable' );
    
    % Discard repeated points.
    sl.pts = sl.pts(ia,:);
    
    % Reindex cellvxs and discard repetitions in each cell.
    % We assume that when the same vertex occurs more than once, all its
    % repetitions are consecutive.
    if iscell(sl.cellvxs)
        numcells = length(sl.cellvxs);
        for i=1:numcells
            sl.cellvxs{i} = unrepcells( ic(sl.cellvxs{i}) );
        end
    else
        numcells = size(sl.cellvxs,1);
        sl.cellvxs(sl.cellvxs>0) = ic(sl.cellvxs(sl.cellvxs>0));
        for i=1:numcells
            sl.cellvxs(i,:) = unreparray( sl.cellvxs(i,:) );
        end
    end
    
    switch calltype
        case 'm'
            m.secondlayer.cell3dcoords = sl.pts;
            for i=1:numcells
                m.secondlayer.cells(i).vxs = sl.cellvxs{i}';
            end
            m = completesecondlayer( m );
            varargout{1} = m;
        case 's'
            varargout{1} = sl;
        case 'p'
            varargout{1} = sl.pts;
            varargout{2} = sl.cellvxs;
    end
            
end

function a = unreparray( a )
    len = length(a);
    a = a(a>0);
    rep = a==a([2:end 1]);
    a(rep) = [];
    if length(a) < len
        a(len) = 0;
    end
end

function a = unrepcells( a )
    rep = a==a([2:end 1]);
    a(rep) = [];
end

