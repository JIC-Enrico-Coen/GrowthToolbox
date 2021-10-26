function plottemps( mesh, temperatures )
%PLOTTEMPS(MESH)  Plot a mesh as a surface.
    numcells = size(mesh.tricellvxs,1);
    xs = reshape( mesh.nodes(mesh.tricellvxs(:,1:3)',1),
            3, numcells );
    ys = reshape( mesh.nodes(mesh.tricellvxs(:,1:3)',2),
            3, numcells );
    zs = reshape( mesh.morphogens(mesh.tricellvxs(:,1:3)',mesh.globalProps.activeGrowth),
            3, numcells );
    fill3(xs,ys,zs,zs);
    lo = min(min( mesh.nodes(:,1:2) ) );
    hi = max(max( mesh.nodes(:,1:2) ) );
    maxz = max(mesh.morphogens(:,mesh.globalProps.activeGrowth));
    if maxz <= 0, maxz = 1; end
    axis( [ lo, hi, lo, hi, 0, maxz ] )
    grid on
    axis square
end
