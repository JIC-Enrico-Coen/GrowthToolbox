function volcells = unionVolCells( varargin )
%volcells = unionVolCells( volcells1, volcells2, ... )
%   Construct a volcells that is the union of the given ones.
%
%volcells = unionVolCells( manyvolcells )
%   manyvolcells is a struct or cell array of volcells structures. Take the
%   union of them.

    allvolcells = structArgsToArray( varargin{:} );

    if isempty( allvolcells )
        volcells = [];
        return;
    end
    
    volcells = allvolcells(end);
    for i=(length(allvolcells)-1):-1:1
        volcells = unionVolCells2( allvolcells(i), volcells );
    end
end

function volcells = unionVolCells2( volcells1, volcells2 )
%              vxs3d: [24×3 double]
%            facevxs: {14×1 cell}
%          polyfaces: {[14×1 double]}
%      polyfacesigns: {[14×1 logical]}
%               vxfe: [24×1 uint32]
%               vxbc: [24×4 double]
%            edgevxs: [36×2 double]
%          edgefaces: {36×1 cell}
%          faceedges: {14×1 cell}
%        atcornervxs: [24×1 logical]
%          onedgevxs: [36×1 logical]
%         surfacevxs: [24×1 logical]
%       surfaceedges: [36×1 logical]
%       surfacefaces: [14×1 logical]
%     surfacevolumes: 1

    nvx1 = size( volcells1.vxs3d, 1 );
    ne1 = size( volcells1.edgevxs, 1 );
    nf1 = size( volcells1.facevxs, 1 );
    
    volcells.vxs3d = [ volcells1.vxs3d; volcells2.vxs3d ];
    volcells.facevxs = [ volcells1.facevxs; addto( nvx1, volcells2.facevxs ) ];
    volcells.polyfaces = [ volcells1.polyfaces; addto( nf1, volcells2.polyfaces ) ];
    volcells.polyfacesigns = [ volcells1.polyfacesigns; volcells2.polyfacesigns ];
    volcells.vxfe = [ volcells1.vxfe; volcells2.vxfe ];
    volcells.vxbc = [ volcells1.vxbc; volcells2.vxbc ];
    volcells.edgevxs = [ volcells1.edgevxs; addto( nvx1, volcells2.edgevxs ) ];
    volcells.edgefaces = [ volcells1.edgefaces; addto( nf1, volcells2.edgefaces ) ];
    volcells.faceedges = [ volcells1.faceedges; addto( ne1, volcells2.faceedges ) ];
    volcells.atcornervxs = [ volcells1.atcornervxs; volcells2.atcornervxs ];
    volcells.onedgevxs = [ volcells1.onedgevxs; volcells2.onedgevxs ];
    volcells.surfacevxs = [ volcells1.surfacevxs; volcells2.surfacevxs ];
    volcells.surfaceedges = [ volcells1.surfaceedges; volcells2.surfaceedges ];
    volcells.surfacefaces = [ volcells1.surfacefaces; volcells2.surfacefaces ];
    volcells.surfacevolumes = [ volcells1.surfacevolumes; volcells2.surfacevolumes ];
end

function vals = addto( n, vals )
    if iscell( vals )
        for i=1:numel(vals)
            vals{i} = vals{i}+n;
        end
    else
        vals = vals + n;
    end
end

function allargs = structArgsToArray( varargin )
    numvals = zeros( nargin, 1 );
    for i=1:nargin
        numvals(i) = numel(varargin{i});
    end
    
    ai = sum( numvals );
    if ai==0
        allargs = [];
        return;
    end
    
    for i=nargin:-1:1
        v = varargin{i};
        n = numel( v );
        ai = ai - n;
        if isstruct( v )
            allargs( (ai+1):(ai+n) ) = v;
        elseif iscell( v )
            allargs( (ai+1):(ai+n) ) = [ v{:} ];
        end
    end
end
