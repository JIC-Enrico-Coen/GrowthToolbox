function m = invalidateLineage( m, t )
%m = invalidateLineage( m, t )
%   Invalidate the lineage info for all times greater than t.
%   It is possible that some cells may exist for which there is no valid
%   lineage information.  These cells are allocated new ids and treated as
%   if they had just been created.

    if nargin < 2
        t = m.globalDynamicProps.currenttime;
    end
    
    change = false;
    
    firstinvalidcellid = find( m.secondlayer.cellidtotime(:,1) > t, 1 );
    if firstinvalidcellid <= length(m.secondlayer.cellparent)
        m.secondlayer.cellparent( firstinvalidcellid:end ) = [];
        m.secondlayer.cellidtoindex( firstinvalidcellid:end ) = [];
        m.secondlayer.cellidtotime( firstinvalidcellid:end, :) = [];
        change = true;
    end
    invalidcells = ~isExtantCell( m, m.secondlayer.cellid );
    if ~isempty(firstinvalidcellid)
        invalidcells = invalidcells | (m.secondlayer.cellid >= firstinvalidcellid);
    end
    if any(invalidcells)
            % All of the cells listed in invalidcells must be allocated new ids
            % and given lineage info as if they had just been created from
            % nothing.
            firstinvalidcellid = min(m.secondlayer.cellid(invalidcells));
            replacementcellids = (firstinvalidcellid:(firstinvalidcellid+sum(invalidcells)-1))';
            m.secondlayer.cellid(invalidcells) = replacementcellids;
            m.secondlayer.cellidtotime(replacementcellids,:) = m.globalDynamicProps.currenttime;
            m.secondlayer.cellparent(replacementcellids) = 0;
            change = true;
        
            fprintf( 1, '%d cells with invalid lineage were reassigned ids.\n', sum(invalidcells) );
%             fprintf( 1, '**** Current cells have invalid cellid:\n' );
%             bad = m.secondlayer.cellid > firstinvalidcellid;
%             fprintf( 1, ' %d', find(bad) );
%             fprintf( 1, '\n' );
%             fprintf( 1, ' %d', m.secondlayer.cellid(bad) );
%             fprintf( 1, '\n' );
    end
    if change
        m.secondlayer.cellidtoindex = zeros( length(m.secondlayer.cellparent), 1 );
        m.secondlayer.cellidtoindex(m.secondlayer.cellid) = (1:length(m.secondlayer.cellid))';
    end
    trimtimes = m.secondlayer.cellidtotime(:,2) > t;
    if any(trimtimes)
        m.secondlayer.cellidtotime(trimtimes > t,2) = t;
        change = true;
    end
    if m.globalProps.validitytime > t
        m.globalProps.validitytime = t;
        change = true;
    end
    
    if change
        % [~] = saveStaticPart( m );
    end
    checklineagevalid( m.secondlayer );
end