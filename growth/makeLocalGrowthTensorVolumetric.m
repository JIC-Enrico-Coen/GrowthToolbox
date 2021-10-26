function G = makeLocalGrowthTensorVolumetric( gpar, gpar2, gper, gradpol, gradpol2, gradpolthresh )
%G = makeLocalGrowthTensorVolumetric( gpar, gpar2, gper2, gradpol, gradpolthresh )
%   Construct growth tensors for a volumetric element, given the values of
%   the growth-determining morphogens at each of its vertexes.
%   The result is returned in the frame of its own principal axes, and
%   therefore the skew components are omitted.  A growth tensor is returned
%   for each vertex; these all have the same principal frame.
%
%   gpar, gpar2, gper are the absolute growth rates along the three
%   principal axes.
%   gradpol is the polarisation gradient.
%   gradpolthresh is a threshold such that if the length of gradpol is
%   below the threshold, the growth tensor is calculated as isotropic.
%
%   The result is a set of growth tensors in the global frame of
%   reference, one for each vertex of the finite element.

    if nargin < 5
        gradpolthresh = 0;
    end
    
    if gradpolthresh < 0
        isotropic = false;
        isotropic2 = false;
    else
        isotropic = sum(gradpol.^2,2) <= gradpolthresh^2;
        isotropic2 = sum(gradpol2.^2,2) <= gradpolthresh^2;
    end
    if isotropic
        if isotropic2
            % Isotropic in all directions.
            g = (gpar+gpar2)/2;
            gpar = g;
            gpar2 = g;
            gper = g;
        else
            % Isotropic in directions perpendicular to gradpol2.
            g = (gpar+gper)/2;
            gpar = g;
            gper = g;
        end
    elseif isotropic2
        % Isotropic in directions perpendicular to gradpol.
        g = (gpar2+gper)/2;
        gpar2 = g;
        gper = g;
    end
%     if isempty(gper)
%         gper = gpar2;
%     end
    G = [ gpar, gpar2, gper ];
end
