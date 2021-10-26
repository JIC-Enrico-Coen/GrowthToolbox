function plotspringmesh(mesh,color,vels,forces)
%plotspringmesh(MESH,COLOR,VELS,FORCES)  Plot a mesh as a surface.
    if nargin < 2, color = 'growth'; end
    haveVels = nargin >= 3;
    haveForces = nargin >= 4;

    mesh = makeTRIvalid( mesh );
    numcells = size(mesh.tricellvxs,1);
    xs = reshape( mesh.nodes(mesh.tricellvxs(:,1:3)',1), ...
             3, numcells );
    ys = reshape( mesh.nodes(mesh.tricellvxs(:,1:3)',2), ...
             3, numcells );
    zs = reshape( mesh.nodes(mesh.tricellvxs(:,1:3)',3), ...
             3, numcells );
    if (strcmp(color,'growth'))
        cs = reshape( mesh.morphogens(mesh.tricellvxs(:,1:3)',mesh.globalProps.activeGrowth), ...
                 3, numcells );
    elseif (strcmp(color,'strain'))
        cs = reshape(...
                sum( ...
                    (mesh.edgelinsprings(mesh.celledges(:,1:3),2) ...
                     ./ mesh.edgelinsprings(mesh.celledges(:,1:3),3)) ...
                    - 1 )/3, ...
            3, numcells );
    elseif (strcmp(color,'force'))
        for i=1:size(mesh.tricellvxs,1)
            cs(:,i) = norm( forces(mesh.tricellvxs(i,1)) ) ...
                    + norm( forces(mesh.tricellvxs(i,2)) ) ...
                    + norm( forces(mesh.tricellvxs(i,3)) );
        end
    end
    if size(mesh.tricellvxs,1) > 0
        fill3(xs,ys,zs,cs);
        lo = min(min( mesh.nodes ) );
        hi = max(max( mesh.nodes ) );
        if (lo >= hi)
            lo = lo-1;
            hi = hi-1;
        end
        lo = floor(lo);
        hi = ceil(hi);
        if lo > -2, lo = -2; end
        if hi < 2, hi = 2; end
        if lo > -hi, lo = -hi; end
        if hi < -lo, hi = -lo; end
    else
        lo = -2; hi = 2;
    end
    axis( [ lo, hi, lo, hi, lo, hi ] )
    grid on
    axis square
end
