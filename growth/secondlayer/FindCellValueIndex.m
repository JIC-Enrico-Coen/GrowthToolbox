function cvIndex = FindCellValueIndex( m, cv, messageprefix, complain )
%mgenIndex = FindCellValueIndex( m, cv, message )
%   Find the index of any cell factor.  Nonexistent factors return zero.
%   The messageprefix argument is optional and defaults to the
%   name of this procedure.  It will be prefixed to every warning message
%   about non-existent morphogens.

    if isempty( m ) || ~hasSecondLayer( m )
        cvIndex = [];
        return;
    end
    if nargin < 3
        messageprefix = mfilename();
    end
    if nargin < 4
        complain = false;
    end
    if isnumeric( cv )
        cv = abs(cv);
        okindexmap = (1 <= cv) & (cv <= size(m.secondlayer.cellvalues,2)) & (cv==int32(cv));
        badindexes = cv(~okindexmap & (cv ~= 0));
        if complain && ~isempty(messageprefix) && ~isempty(badindexes)
            if length(badindexes)==1
                fprintf( 1, '%s: No such cell value index as %g.\n', messageprefix, badindexes );
            else
                fprintf( 1, '%s: No such cell value indexes as', messageprefix );
                fprintf( 1, ' %d', badindexes );
                fprintf( 1, '.\n' );
            end
        end
        cv( ~okindexmap ) = 0;
        cvIndex = cv;
    elseif ischar(cv)
        cv = lower(cv);
        if isfield( m.secondlayer.valuedict.name2IndexMap, cv )
            cvIndex = m.secondlayer.valuedict.name2IndexMap.(cv);
        else
            if complain && ~isempty(messageprefix)
                fprintf( 1, '%s: No such cell value as "%s".\n', messageprefix, cv );
            end
            cvIndex = 0;
        end
    elseif iscell(cv)
        cvIndex = [];
        for i=1:length(cv)
            ci = FindCellValueIndex( m, cv{i}, messageprefix, complain );
            if isempty(ci)
                ci = 0;
            end
            cvIndex = [ cvIndex ci ];
        end
    end
end
