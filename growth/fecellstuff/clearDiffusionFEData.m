function dd = clearDiffusionFEData()
%dd = clearDiffusionFEData()
%   Discard the diffusion data and mark it dirty.
%
%   See also: getDiffusionFEData.

    dd = struct( 'clean', false );
end