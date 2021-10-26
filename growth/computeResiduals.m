function m = computeResiduals( m, retainFraction )
%m = computeResiduals( m, retainFraction )
%   Given m.displacements, this computes the following components of
%   m.celldata:
%       displacementStrain
%       residualStrain
%   If required (i.e. if celldata.actualGrowthTensor exists), it also
%   computes:
%       actualGrowthTensor

    if nargin < 2
        retainFraction = 0;
    end
    numCells = getNumberOfFEs(m);
    if isempty(m.displacements) || (m.globalProps.timestep==0)
        for ci=1:numCells
            m.celldata(ci).residualStrain = zeros( size(m.celldata(ci).residualStrain) );
        end
    else
        vorticities = zeros(3,3,6,numCells);
        for ci=1:numCells
            if usesNewFEs(m)
                vxs = m.FEconnectivity.allfevxs(ci,:);
            else
                trivxs = m.tricellvxs(ci,:);
                vxs = [ trivxs*2-1, trivxs*2 ];
            end
            if retainFraction==0
                 m.celldata(ci) = computeDisplacementStrains( ...
                    m.celldata(ci), m.displacements(vxs,:) );
            else
                % We only need to compute the vorticities when there is
                % non-zero retained strain, because we need to rotate the
                % residual strain according to the growth in the last step.
                [m.celldata(ci),vort] = computeDisplacementStrains( ...
                    m.celldata(ci), m.displacements(vxs,:) );
                vorticities(:,:,:,ci) = vort;
            end
        end
        m = computeResidualStrains( m, retainFraction, vorticities );
    end
end
