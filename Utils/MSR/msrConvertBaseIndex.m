function msr = msrConvertBaseIndex( msr, baseIndex )
%msr = msrConvertBaseIndex( msr, baseIndex )
%   Convert an MSR structure such as returned by msrfilereader or as
%   supplied to msrfilewriter between 0-indexing and 1-indexing.
%
%   MSR files use 0-indexing for those fields that consist of indexes into
%   other fields, i.e. the lower index is zero.  Matlab indexes arrays from
%   1.  Therefore it is necessary to convert between 0- and 1-indexing in
%   order to process MSR data in Matlab.
%
%   baseIndex is the indexing mode that is required for the result.
%
%   If baseIndex is zero, the given msr structure is assumed to currently
%   be 1-indexed, and 1 is subtracted from every array index it contains.
%
%   If baseIndex is 1, the given msr structure is assumed to currently
%   be 0-indexed, and 1 is added to every array index it contains.
%
%   This procedure will rarely be called by the end user, as msrfilereader
%   and msrfilewriter automatically call this already.
    
    indexFields = { 'EDGE', 'FACE' };
    if baseIndex == 1
        increment = 1;
    else
        increment = -1;
    end
    if isfield( msr, 'OBJECT' )
        for i=1:length(msr.OBJECT)
            for fi=1:length(indexFields)
                incrementField( i, indexFields{fi} );
            end
        end
    end
    
function incrementField( oi, fieldname, baseIndex )
    if isfield( msr.OBJECT{oi}, fieldname )
        msr.OBJECT{oi}.(fieldname) = msr.OBJECT{oi}.(fieldname) + increment;
    end
end
end
