function mesh = deletebspointsnear(mesh,p,d)
    dsq = d*d;
    np = 0;
    pointstodelete = [];
    for pi=1:size(mesh.nodes,1)
        v = [mesh.nodes(pi,1:2), 0] - p;
        if dot(v,v) <= dsq
            np = np+1;
            pointstodelete(np) = pi;
        end
    end
    mesh = deletepoints(mesh,pointstodelete);
end
