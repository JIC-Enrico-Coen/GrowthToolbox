function n = getNumberOf( m, thing )
    switch thing
        case 'fevx'
            n = getNumberOfVertexes( m );
        case 'fe'
            n = getNumberOfFEs( m );
        case 'feface'
            n = getNumberOfFaces( m );
        case 'feedge'
            n = getNumberOfEdges( m );
        case 'cell'
            n = getNumberOfCells( m );
        case 'cellvx'
            n = getNumberOfCellvertexes( m );
        case 'mgen'
            n = getNumberOfMorphogens( m );
        case 'cellmgen'
            n = getNumberOfCellFactors( m );
        case 'celledge'
            n = getNumberOfCellEdges( m );
        case 'volvx'
            n = getNumberOfVolVertexes( m );
        case 'voledge'
            n = getNumberOfVolEdges( m );
        case 'volface'
            n = getNumberOfVolFaces( m );
        case 'volsolid'
            n = getNumberOfVolCells( m );
        otherwise
            n = -1;
    end
end
