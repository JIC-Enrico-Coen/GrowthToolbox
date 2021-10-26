function axes = axesFromCell( vxs )
%axes = axesFromCell( vxs )
%    Compute a frame of reference for a triangular prism cell.
%    One axis is parallel to the xi isoparametric coordinate, one
%    is perpendicular to xi in the xi-eta plane, and the third is
%    perpendicular to both.  Its direction should roughly coincide with the
%    zeta axis.
%    The vectors vxs are assumed to be column vectors.  There must be 6 of
%    them: vxs(1:3) are the bottom face and vxs(4:6) are the top face.
    xiV = (vxs(:,2) - vxs(:,1) + vxs(:,5) - vxs(:,4))/2;
    xiV = xiV/norm(xiV);
    etaV = (vxs(:,3) - vxs(:,1) + vxs(:,6) - vxs(:,4))/2;
%    etaV = etaV - xiV*(dot(etaV,xiV));
    etaV = etaV - xiV*(dotproc1(etaV,xiV));
%    etaV = etaV - xiV*(etaV'*xiV);
    etaV = etaV/norm(etaV);
    zetaV = crossproc1(xiV,etaV);
    axes = [ xiV, etaV, zetaV ];
end
