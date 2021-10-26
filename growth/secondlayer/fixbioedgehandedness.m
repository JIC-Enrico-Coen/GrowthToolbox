function [secondlayer,numfixed] = fixbioedgehandedness( secondlayer )
%[secondlayer,numfixed] = fixbioedgehandedness( secondlayer )
%   Assuming that secondlayer is otherwise valid, fix all mis-oriented
%   edges.

    numfixed = 0;
    for ei=1:size( secondlayer.edges, 1 )
        edgedata = secondlayer.edges( ei, : );
        v1 = edgedata(1);
        v2 = edgedata(2);
        cell1 = edgedata(3);
        cell2 = edgedata(4);
        if cell1>0
            cvxs = secondlayer.cells(cell1).vxs;
            v1i = find(cvxs==v1,1);
            v2i = mod(v1i,length(cvxs)) + 1;
            if cvxs(v2i) ~= v2
                secondlayer.edges(ei,[1 2]) = [v2 v1];
                numfixed = numfixed+1;
            end
        elseif cell2>0
            cvxs = secondlayer.cells(cell2).vxs;
            v2i = find(cvxs==v2,1);
            v1i = mod(v2i,length(cvxs)) + 1;
            if cvxs(v1i) ~= v2
                secondlayer.edges(ei,[1 2]) = [v2 v1];
                numfixed = numfixed+1;
            end
        end
    end
end

