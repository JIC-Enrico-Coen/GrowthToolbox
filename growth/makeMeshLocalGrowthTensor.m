function gt = makeMeshLocalGrowthTensor( m, ci )
%gt = makeMeshGrowthTensor( m, ci )
%   Calculate the growth tensors at the vertexes of the cell ci in the
%   local frame of ci.

    trivxs = m.tricellvxs(ci,:);
    growthmgens = FindMorphogenRole( m, 'KAPAR', 'KAPER', 'KBPAR', 'KBPER', 'KNOR' );
    if strcmp( m.globalProps.thicknessMode, 'scaled' )
        gthick = [];
    else
        gthick = getEffectiveMgenLevels( m,  growthmgens(5), trivxs );
    end
    mgens = getEffectiveMgenLevels( m, growthmgens(1:4), trivxs );
    gt = makeLocalGrowthTensorNEW( ...
            mgens(:,1), ...
            mgens(:,2), ...
            mgens(:,3), ...
            mgens(:,4), ...
            gthick, ...
            m.gradpolgrowth(ci,:) );
end
