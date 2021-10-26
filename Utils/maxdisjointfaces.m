function selfaces = maxdisjointfaces( faces )
%selfaces = maxdisjointfaces( faces )
%   faces is an N*K matrix listing the K vertex indexes of a
%   set of N faces.  This procedure selects a maximal subset of the faces
%   such that no two faces share a vertex.  The result SELFACES is a list of
%   indexes of the selected faces.

    unused = true(max(faces(:)),1);
    numfaces = size(faces,1);
    selfaces = false(numfaces);
    for fi=1:numfaces
        if all(unused(faces(fi,:)))
            selfaces(fi) = true;
            unused(faces(fi,:)) = false;
        end
    end
    selfaces = find(selfaces);
end
