function m = initialiseCellIDData( m )
%m = initialiseCellIDData( m )
%   Create new lineage data for the cellular layer, presumed to have just
%   been created.

    numcells = length(m.secondlayer.cells);
    
    m.secondlayer.cellid = int32( (1:numcells)' );
    m.secondlayer.cellidtoindex = m.secondlayer.cellid;
    m.secondlayer.cellparent = zeros(numcells,1,'int32');
    m.secondlayer.cellidtotime = m.globalDynamicProps.currenttime+zeros(numcells,2,'double');
end
