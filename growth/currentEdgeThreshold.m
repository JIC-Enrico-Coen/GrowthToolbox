function eth = currentEdgeThreshold( m )
    if m.globalProps.longSplitThresholdPower==0
        eth = m.globalProps.thresholdsq;
    elseif usesNewFEs( m )
        eth = m.globalProps.thresholdsq * ...
              ((m.globalDynamicProps.currentVolume/m.globalProps.initialVolume) ^ ...
               (0.6667*m.globalProps.longSplitThresholdPower));
    else
        eth = m.globalProps.thresholdsq * ...
              ((m.globalDynamicProps.currentArea/m.globalProps.initialArea) ^ ...
               m.globalProps.longSplitThresholdPower);
    end
    subdivmgen = FindMorphogenRole( m, 'EDGESPLIT' );
    if subdivmgen > 0
        mgen = m.morphogens(:,subdivmgen);
        mgenPerEdge = perVertextoperEdge( m, mgen, 'mid' );
        if any( mgen > 0 )
            eth = eth * mgenPerEdge;
        end
    end
end
