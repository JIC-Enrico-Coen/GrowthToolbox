function G = makeLocalGrowthTensor( gpar, gper, bendpar, bendper, ...
                                    gthick, gradpol, gradpolthresh ...
                                  )
%G = makeLocalGrowthTensor( gpar, gper, gradpol, gthick, ...
%                           bendpar, bendper )
%Compute a growth tensor in the local frame.
%
%   OBSOLETE.

    if nargin < 7
        gradpolthresh = 0;
    end
    
    apar = gpar-bendpar;
    aper = gper-bendper;
    bpar = gpar+bendpar;
    bper = gper+bendper;
    G = makeLocalGrowthTensorNEW( apar, aper, bpar, bper, ...
                                  gthick, gradpol, gradpolthresh );
end
