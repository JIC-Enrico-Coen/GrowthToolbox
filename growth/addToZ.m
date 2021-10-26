function m = addToZ( m, addz, ax )
    m.saved = 0;
    if usesNewFEs( m )
        m.FEnodes(:,ax) = m.FEnodes(:,ax) + addz;
    else
        m.nodes(:,ax) = m.nodes(:,ax) + addz;
        if m.globalProps.prismnodesvalid
            m.prismnodes(:,ax) = m.prismnodes(:,ax) + ...
                reshape( [addz addz]', size(m.nodes,1)*2, 1 );
        else
            if ~m.prismsvalid
                complain( 'addToZ: prisms are not valid.\n' );
                return;
            end
        end
    end
    m.globalProps.alwaysFlat = false;
    m.globalProps.twoD = false;
    m = recalc3d( m );
    m.initialbendangle = m.currentbendangle;
end
