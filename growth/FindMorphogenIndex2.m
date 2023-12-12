function mgenIndex = FindMorphogenIndex2( m, mgen, complain )
%mgenIndex = FindMorphogenIndex2( m, mgen, complain )
%   Find the index of any morphogen.  mgen can be an array of morphogen
%   indexes, a morphogen name, or a cell array of morphogen names or
%   indexes.  The list of indexes returned will be zero for invalid names
%   or indexes.
%
%   Warning messages will be given if the complain argument is present and true.
%
%   SEE ALSO: FindMorphogenIndex

    if isempty( m )
        mgenIndex = [];
        return;
    end
    if nargin < 3
        complain = false;
    end
    if isnumeric( mgen )
        valid = (1 <= mgen) & (mgen <= size(m.morphogens,2)) & (mgen==int32(mgen));
        badindexes = mgen(~valid);
        if complain && ~isempty(badindexes)
            if length(badindexes)==1
                timedFprintf( 1, 'No such morphogen index as %g.\n', badindexes );
            else
                timedFprintf( 1, 'No such morphogen indexes as' );
                fprintf( 1, ' %d', badindexes );
                fprintf( 1, '.\n' );
            end
        end
        mgenIndex = mgen;
        mgenIndex(~valid) = 0;
    elseif ischar(mgen)
        mgen = upper(mgen);
        if isfield( m.mgenNameToIndex, mgen )
            mgenIndex = m.mgenNameToIndex.(mgen);
        else
            if complain
                timedFprintf( 1, 'No such morphogen as "%s".\n', mgen );
            end
            mgenIndex = 0;
        end
    elseif iscell(mgen)
        mgenIndex = zeros(1,length(mgen));
        for i=1:length(mgen)
            mi = FindMorphogenIndex2( m, mgen{i}, complain );
            if ~isempty(mi)
                mgenIndex(i) = mi;
            end
        end
    end
end
