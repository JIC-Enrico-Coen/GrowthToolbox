function v = insertFixedDFS3( v, renumber, numfulldfs, stitchedDFSets, fixedDFs, fixedValues )
%v = insertFixedDFS( v, renumber, numfulldfs, stitchedDFSets, fixedDFs )
%    v is a vector or matrix indexed on its first dimension by reduced
%    degrees of freedom. Insert the full degrees of freedom according to
%    the renumbering. For those degrees listed in fixedDFs, set the
%    inserted items to the corresponding members of fixedValues. For the
%    stitched sets, set the inserted items to the values of their
%    representative row.

    if isempty(v)
        v = zeros( numfulldfs, 1 );
        return;
    end
        
    if ~isempty(renumber)
        result = zeros( numfulldfs, 1 );
        result( renumber ) = v;
        v = result;
    end
    
    if iscell(stitchedDFSets)
        for i=1:length(stitchedDFSets)
            vxs = stitchedDFSets{i};
            v(vxs(2:end)) = v(vxs(1));
        end
    else
        for i=1:size(stitchedDFSets,1)
            vxs = stitchedDFSets(i,:);
            v(vxs(2:end)) = v(vxs(1));
        end
    end
    
    if ~isempty( fixedDFs )
        v(fixedDFs) = fixedValues;
    end
end
