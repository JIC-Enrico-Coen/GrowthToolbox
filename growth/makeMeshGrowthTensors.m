function m = makeMeshGrowthTensors( m )
%m = makeMeshGrowthTensors( m )
%   Calculate the growth tensors at every vertex of every cell.

    full3d = usesNewFEs( m );
    isVolumetric = isVolumetricMesh( m );
    if full3d
        allfevxs = m.FEsets(1).fevxs;
    else
        allfevxs = m.tricellvxs;
    end
    numcells = size(allfevxs,1);
    if isVolumetric
        growthmgens = FindMorphogenRole( m, 'KPAR','KPAR2','KPER', false );
        if growthmgens(3)==0
            growthmgens(3) = growthmgens(2);
        end
    else
        growthmgens = FindMorphogenRole( m, 'KAPAR', 'KAPER', 'KBPAR', 'KBPER' );
        thicknessmgen = FindMorphogenRole( m, 'KNOR' );
    end
    
    allmgens = getEffectiveMgenLevels( m, growthmgens );  % Error: does not include thickness.
    if isVolumetric
        vxsPerFE = 4;
    else
        vxsPerFE = 6;
    end
    if all(allmgens(:)==0)
        for ci=1:numcells
            m.celldata(ci).Glocal = zeros( vxsPerFE, 3 );
            m.celldata(ci).Gglobal = zeros( vxsPerFE, 6 );
        end
        return;
    end
%     checkNewMethod = zeros( size(allfevxs,2), 6, getNumberOfFEs(m) );
    for ci=1:numcells
        fevxs = allfevxs(ci,:);
        if ~isVolumetric
            switch m.globalProps.thicknessMode
                case { 'scaled', 'direct' }
                    gthick = [];
                otherwise
                    gthick = getEffectiveMgenLevels( m, thicknessmgen, fevxs );
            end
        end
%         mgens = getEffectiveMgenLevels( m, growthmgens, fevxs );
        mgens = allmgens( fevxs, : );
        if isVolumetric
            Glocal = makeLocalGrowthTensorVolumetric( mgens(:,1), mgens(:,2), mgens(:,3), m.gradpolgrowth(ci,:,:), m.gradpolgrowth2(ci,:,:), 0 );
        else
            Glocal = makeLocalGrowthTensorNEW( ...
                        mgens(:,1), ...
                        mgens(:,2), ...
                        mgens(:,3), ...
                        mgens(:,4), ...
                        gthick, ...
                        m.gradpolgrowth(ci,:,:), ...
                        0 ); % m.globalProps.mingradient );
        end
        m.celldata(ci).Glocal = Glocal;
        if all(Glocal(:)==0)
            m.celldata(ci).Gglobal = zeros( vxsPerFE, 6 );
        elseif isempty( m.cellFramesB )
%             m.celldata(ci).Gglobal = globalGrowthTensor( m.cellFrames(:,:,ci)', Glocal );
            m.celldata(ci).Gglobal = ...
                    rotateGrowthTensor( [ Glocal, zeros( size(Glocal,1), 3 ) ], ...
                                        m.cellFrames(:,:,ci) );
        else
            m.celldata(ci).Gglobal = ...
                    [ rotateGrowthTensor( [ Glocal(1:3,:), zeros( 3, 3 ) ], ...
                                          m.cellFramesA(:,:,ci) );
                      rotateGrowthTensor( [ Glocal(4:6,:), zeros( 3, 3 ) ], ...
                                          m.cellFramesB(:,:,ci) ) ];
        end
        xxxx = 1;
    end
end
