function whichNodes = selectNodes( m, whichNodes )
%whichNodes = selectNodes( m, whichNodes )
    if isempty(whichNodes), return; end
        
    if (length(whichNodes)==1) && (whichNodes(1)==0)
        whichNodes = true( size(m.nodes,1), 1 );
    end
end
