function [m,numsplit,numunsplit] = leaf_remesh( m, varargin )
%[m,didsplit] = leaf_remesh( m, varargin )
%   Perform remeshing. This is done automatically during each simulation
%   step, but sometimes one may want to force a remeshing pass.
%
%   The various remeshing transformations are notrmally controlled by
%   boolean flags in m.globalProps:
%
%   m.globalProps.allowSplitLongFEM determined whether long edges can be
%   split.
%
%   m.globalProps.allowSplitBentFEM (for leaf-like meshes only) determines
%   whether remeshing should take place around sharp creases in the mesh.
%
%   m.globalProps.allowSplitThinFEM is not yet supported. It is for eliding
%   very short edges.
%
%   m.globalProps.thresholdmgen is not yet supported. It specifies a
%   maximum allowed variation along an edge of any morphogen whose
%   interpolation mode is 'mid'.
%
%   For each of these there is a corresponding option. If unspecified or
%   empty, then the corresponding flag takes effect. If true or false, it
%   overrides the corresponding flag. The flag itself is not changed.
%
%   The option names corresponding to the above flags are 'longedges',
%   'bentedges', 'thinedges', and 'mgenedges'.
%
%   There is one further option:
%
%   repeat: an upper bound on the number of remeshing passes to be made.
%   By default this is 1, and for leaf-like meshes there is no need to set
%   it higher. For volumetric meshes, it is often not possible to split all
%   eligible edges simultaneously, and a maximal set of simultaneously
%   splittable edges will be chosen. This can easily be only half the
%   eligible edges.
%
%   The numsplit result gives the number of edges that were split.
%
%   The numunsplit result gives the number of edges eligible to be split
%   that were not split.


    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'longedges', [], 'bentedges', [], 'thinedges', [], 'mgenedges', [], 'repeat', 1 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'longedges', 'bentedges', 'thinedges', 'mgenedges', 'repeat' );
    if ~ok, return; end
    
    numiters = 0;
    didsplit = true;
    n = Inf;
    numsplit = 0;
    numunsplit = 0;
    while (numiters < s.repeat) && didsplit
        [m,didsplit,splitdata,numunsplit] = trysplit( m, s.longedges, s.bentedges, s.thinedges, s.mgenedges );
        numsplit1 = size(splitdata,1);
        numsplit = numsplit + numsplit1;
        if didsplit
            n = numsplit1;
            numiters = numiters+1;
        end
    end
end
