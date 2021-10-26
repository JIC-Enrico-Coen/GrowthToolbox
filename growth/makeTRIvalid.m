function m = makeTRIvalid( m )
    if m.globalProps.trinodesvalid, return; end
    if ~m.globalProps.prismnodesvalid, return; end
    m.globalProps.trinodesvalid = true;
    m.nodes = (m.prismnodes(1:2:end,:) + m.prismnodes(2:2:end,:))/2;
end

    