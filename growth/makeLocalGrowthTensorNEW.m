function G = makeLocalGrowthTensorNEW( apar, aper, bpar, bper, ...
                                       gthick, gradpol, gradpolthresh )
%G = makeLocalGrowthTensorNEW( apar, aper, bpar, bper, ...
%                              gthick, gradpol, gradpolthresh )
%   Construct growth tensors for a pentahedral element, given the values of
%   the growth-determining morphogens at the three vertexes of its midplane.
%   The result is returned in the frame of its own principal axes, and
%   therefore the skew components are omitted.  A growth tensor is returned
%   for each vertex; these all have the same principal frame.
%
%   apar, aper, bpar, bper are the absolute growth rates on the A and B
%       sides of the pentahedron.
%   gradpol is the polarisation gradient.
%   gthick is the growth in thickness.  If this is empty, then thickness is
%       being handled non-physically, and for the purposes of constructing
%       growth tensors we use the average of major and minor growth on the
%       top and bottom.
%
%   The result is a set of growth tensors in the global frame of
%   reference, one for each vertex of the pentahedron.  If the triangular
%   vertexes are v1, v2, and v3, the growth tensors are listed for the
%   prism nodes in order: v1*2-1, v2*2-1, v1*2, v3*2-1, v2*2, v3*2.

    if nargin < 7
        gradpolthresh = 0;
    end
    
    if gradpolthresh < 0
        isotropic = false(1,size(gradpol,3));
    else
        isotropic = squeeze( sum(gradpol.^2,2) <= gradpolthresh*gradpolthresh );
    end
    if length(gthick)==6
        gthicka = gthick(1:3);
        gthickb = gthick(4:6);
    else
        gthicka = gthick;
        gthickb = gthick;
    end
    if numel(isotropic)==1
        isotropic = [ isotropic, isotropic ];
    end
    if isotropic(1)
        a = (apar+aper)/2;
        apar = a;
        aper = a;
    end
    if isotropic(2)
        b = (bpar+bper)/2;
        bpar = b;
        bper = b;
    end
    if isempty(gthick)
        gthicka = (apar+aper)/2;
        gthickb = (bpar+bper)/2;
    end
    G = [[ apar, aper, gthicka ];
         [ bpar, bper, gthickb ]];
end
