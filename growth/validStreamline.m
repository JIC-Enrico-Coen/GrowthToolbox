function [oks,errfields] = validStreamline( m, ss, verbose )
    if nargin < 3
        verbose = false;
    end
    if nargin < 2
        ss = m.tubules.tracks;
    end
    oks = true( size(ss) );
    for si=1:length(ss)
        ok = true;
        s = ss(si);
        errfields = {};
        numvxs = length(s.vxcellindex);
        [ok1,errfields] = checklengthInternal( si, s, 'vxcellindex', numvxs, verbose, errfields );  ok = ok && ok1;
        [ok1,errfields] = checklengthInternal( si, s, 'segcellindex', numvxs, verbose, errfields );  ok = ok && ok1;
        if ok1
            if any( s.vxcellindex ~= s.segcellindex )
                if verbose
                    fprintf( 1, '%s, streamline id %d: differing vxcellindex and segcellindex:\n', ...
                        mfilename(), s.id );
                end
                invalids = find( s.vxcellindex ~= s.segcellindex );
                s_vxcellindex = s.vxcellindex(invalids)
                s_segcellindex = s.segcellindex(invalids)
                ok = true;
                xxxx = 1;
%                 BREAKPOINT();
            end
        else
%             BREAKPOINT();
        end
        [ok1,errfields] = checksizeInternal( si, s, 'barycoords', [numvxs,3], verbose, errfields );  ok = ok && ok1;
        [ok1,errfields] = checksizeInternal( si, s, 'globalcoords', [numvxs,3], verbose, errfields );  ok = ok && ok1;
        [ok1,errfields] = checklengthInternal( si, s, 'segmentlengths', max(numvxs-1,0), verbose, errfields );  ok = ok && ok1;
        [ok1,errfields] = checksizeInternal( si, s, 'directionbc', [1,3], verbose, errfields );  ok = ok && ok1;
        [ok1,errfields] = checksizeInternal( si, s, 'directionglobal', [1,3], verbose, errfields );  ok = ok && ok1;
        [ok1,errfields] = checksizeInternal( si, s, 'status', [1,1], verbose, errfields );  ok = ok && ok1;
    
        if ~ok
            oks(si) = false;
            continue;
        end

        if isemptystreamline(s)
            continue;
        end

        % Check that all cell indexes are valid.
        numtris = getNumberOfFEs( m );
        invalidcells = (s.vxcellindex > numtris) | (s.vxcellindex < 0);
        if any( invalidcells )
            if verbose
                fprintf( 1, '%s, streamline id %d: invalid cell indexes:\n', ...
                    mfilename(), s.id, relposerror, poserror );
                invalidcells = s.vxcellindex( invalidcells )
            end
            oks(si) = false;
            continue;
        end

        % Check that bary/global coordinates and directions are consistent.

        TOLERANCE = 1e-3;
        sscale = max(abs(s.globalcoords(:)));
        if sscale==0
            sscale = 1;
        end
        gp = streamlineGlobalPos( m, s );
        poserror = max( abs( gp(:) - s.globalcoords(:) ) );
        relposerror = poserror/sscale;
        if relposerror > TOLERANCE
            if verbose
                fprintf( 1, '%s, streamline id %d: error in global positions of %g (absolute %g).\n', ...
                    mfilename(), s.id, relposerror, poserror );
            end
            xxxx = 1;
            ok = false;
        end
        gdir = streamlineGlobalDirection( m, s );
        direrror = max( abs( gdir(:) - s.directionglobal(:) ) );
        if direrror > TOLERANCE
            if verbose
                fprintf( 1, '%s, streamline id %d: error in global direction of %g.\n', ...
                    mfilename(), s.id, direrror );
            end
            xxxx = 1;
            ok = false;
        end
        
        duplicate = all( abs( s.barycoords(1:(end-1),:) - s.barycoords(2:end,:) ) < TOLERANCE, 2 ) ...
                    & ( s.vxcellindex(1:(end-1)) == s.vxcellindex(2:end) )';
        if false && any(duplicate)
            if verbose
                fprintf( 1, '%s, streamline id %d: %d duplicate vertexes found.\n', ...
                    mfilename(), s.id, sum(duplicate) );
            end
            xxxx = 1;
            if false
                s.barycoords(duplicate,:) = [];
                s.globalcoords(duplicate,:) = [];
                s.vxcellindex(duplicate) = [];
                s.segcellindex(duplicate) = [];
                s.segmentlengths(duplicate) = [];
            end
        end
        
        % Check the correctness of all transitions from one element to
        % another.
        
        % Where any bc is zero and none are 1, it must either be in the
        % same element as its neighbours, or be transferable to their
        % elements across the corresponding edge.
        
        numvxs = length( s.vxcellindex );
        edgeOrVxbc = find( any( s.barycoords==0, 2 ) );
        for i=edgeOrVxbc'
            if i>1
                bc2 = transferBC( m, s.vxcellindex(i), s.barycoords(i,:), s.vxcellindex(i-1) );
                if isempty(bc2)
                    oks(si) = false;
                    xxxx = 1;
                end
            end
            if i<numvxs
                bc2 = transferBC( m, s.vxcellindex(i), s.barycoords(i,:), s.vxcellindex(i+1) );
                if isempty(bc2)
                    oks(si) = false;
                    xxxx = 1;
                end
            end
        end
        
        
        sevs = s.status.severance;
        if ~isempty( sevs)
            sevvxs = [sevs.vertex];
            oksevvxs = (sevvxs >= 1) & (sevvxs <= length(s.vxcellindex));
            if ~all( oksevvxs )
                if verbose
                    fprintf( 1, '%s, streamline %s id %d: %d severings at invalid vertexes.\n', ...
                        mfilename(), s.id, sum(~oksevvxs) );
                end
                xxxx = 1;
            end
            numdupvxs = length(sevvxs) - length(unique(sevvxs));
            if numdupvxs > 0
                if verbose
                    fprintf( 1, '%s, streamline %s id %d: %d duplicate vertexes.\n', ...
                        mfilename(), s.id, numdupvxs );
                end
                xxxx = 1;
            end
        end
        
        oks(si) = ok;
    end
end

function [ok,errfields] = checklengthInternal( si, s, fn, expectedlen, verbose, errfields )
    ok = true;
    if ~isfield( s, fn )
        if verbose
            fprintf( 1, '%s, streamline id %d: field %s missing.\n', ...
                mfilename(), s.id, fn);
        end
        ok = false;
    else
        len = length(s.(fn));
        if len ~= expectedlen
            if verbose
                fprintf( 1, '%s, streamline id %d: field %s has length %d, expected %d.\n', ...
                    mfilename(), s.id, fn, len, expectedlen);
            end
            ok = false;
        end
    end
    if ~ok
        errfields{end+1} = fn;
    end
end

function [ok,errfields] = checksizeInternal( si, s, fn, expectedsize, verbose, errfields )
    ok = true;
    sz = size(s.(fn));
    if length(sz) ~= length(expectedsize)
        if verbose
            fprintf( 1, '%s, streamline id %d: field %s, wrong number of dimensions %d, expected %d.\n', ...
                mfilename(), s.id, fn, length(sz), length(expectedsize) );
        end
        ok = false;
    end
    for i=1:min( length(sz), length(expectedsize) )
        if sz(i) ~= expectedsize(i)
            if verbose
                fprintf( 1, '%s, streamline id %d: field %s, dim %d has size %d, expected %d.\n', ...
                    mfilename(), s.id, fn, i, sz(i), expectedsize(i) );
            end
            ok = false;
        end
    end
    if ~ok
        errfields{end+1} = fn;
    end
end
