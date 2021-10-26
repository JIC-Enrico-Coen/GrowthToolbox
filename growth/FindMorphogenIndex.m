function [mgenIndex,selected] = FindMorphogenIndex( m, mgen, messageprefix, complain )
%[mgenIndex,selected] = FindMorphogenIndex( m, mgen, messageprefix, complain )
%   Find the index of any morphogen.  mgen can be an array of morphogen
%   indexes, a morphogen name, or a cell array of morphogen names or
%   indexes.  The list of indexes returned will exclude all invalid names
%   or indexes.  selected is a boolean map indicating which of the
%   specified morphogens were valid.
%
%   The messageprefix argument is optional and defaults to the name of this
%   procedure.  It will be prefixed to every warning message about
%   non-existent morphogens.  Warning messages will be given if the
%   complain argument is present and true.
%
%   SEE ALSO: FindMorphogenIndex2

    if isempty( m )
        mgenIndex = [];
        selected = [];
        return;
    end
    if nargin < 3
        messageprefix = mfilename();
    end
    if nargin < 4
        complain = false;
    end
    if isnumeric( mgen )
        mgen = abs(mgen);
        selected = (1 <= mgen) & (mgen <= size(m.morphogens,2)) & (mgen==int32(mgen));
        badindexes = mgen(~selected);
        if complain && ~isempty(messageprefix) && ~isempty(badindexes)
            if length(badindexes)==1
                fprintf( 1, '%s: No such morphogen index as %g.\n', messageprefix, badindexes );
            else
                fprintf( 1, '%s: No such morphogen indexes as', messageprefix );
                fprintf( 1, ' %d', badindexes );
                fprintf( 1, '.\n' );
            end
        end
        mgenIndex = mgen(selected);
    elseif ischar(mgen)
        mgen = upper(mgen);
        if isfield( m.mgenNameToIndex, mgen )
            mgenIndex = m.mgenNameToIndex.(mgen);
            selected = true;
        else
            if complain && ~isempty(messageprefix)
                fprintf( 1, '%s: No such morphogen as "%s".\n', messageprefix, mgen );
            end
            mgenIndex = [];
            selected = [];
        end
    elseif iscell(mgen)
        mgenIndex = zeros(1,length(mgen));
        selected = false(1,length(mgen));
        for i=1:length(mgen)
            mi = FindMorphogenIndex( m, mgen{i}, messageprefix, complain );
            selected(i) = ~isempty(mi);
            if ~isempty(mi)
                mgenIndex(i) = mi;
            end
        end
        mgenIndex = mgenIndex( selected );
    end
end
