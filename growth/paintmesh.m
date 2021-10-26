function h = paintmesh( V, I, res )
%paintmesh( V, I, res )  Paint the surface through the vertexes V with
%the image I.  res is the grid interval in units of the maximum diameter of
%V.
%The vertexes are the rows of V.

global stdimage;

    minv = min(V,[],1);
    maxv = max(V,[],1);
    range = max(maxv - minv);
    stepsize = range*res;
    [XI,YI] = meshgrid( minv(1):stepsize:maxv(1), minv(2):stepsize:maxv(2) );
    ZI = griddata(V(:,1),V(:,2),V(:,3),XI,YI);
    h = surf(XI,YI,ZI);
    set(h,'CData',stdimage,'EdgeColor','none','FaceColor','texturemap');
end
