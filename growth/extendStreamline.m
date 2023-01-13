function [m,s,lengthgrown] = extendStreamline( m, s, lengthToGrow, noncolliders )
%[m,s,lengthgrown] = extendStreamline( m, s, lengthToGrow, noncolliders )
%   Extend the si'th streamline of m by a distance len, or until unable to
%   go further.

% fprintf( 1, 'Extending streamline %d by %f.\n', si, len );

    if ~validStreamline( m, s, true )
%         s.directionglobal = streamlineGlobalDirection( m, s );
%         BREAKPOINT( 'Invalid streamline.\n' );
    end
    
    lengthgrown = 0;
    
    if isemptystreamline(s)
        return;
    end

    if lengthToGrow <= 0
        return;
    end
    
    if length(s.vxcellindex)==1
        xxxx = 1;
    end
    
    CLOSE = 1e-5;
    
    remaininglength = lengthToGrow;
    
    if remaininglength <= CLOSE
        return;
    end
    
    if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
        xxxx = 1;
    end
    MAXITERS = 1000;
    numiters = 0;
    ok = true;
    alllengthgrown = [];
%     fprintf( 1, 'Growing streamline by %f.\n', remaininglength );
    while remaininglength > CLOSE
%         s1 = s;
        [m,s,extended,remaininglength,lengthgrown1] = extrapolateStreamline( m, s, remaininglength, noncolliders );
        if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
            xxxx = 1;
        end
        if ~extended
            xxxx = 1;
        end
        alllengthgrown(end+1) = lengthgrown1;
%         if ~extended && (remaininglength <= CLOSE)
%             xxxx = 1;
%         end
        lengthgrown = lengthgrown + lengthgrown1;
        if extended
            if numiters >= MAXITERS
                ok = false;
                break;
            end
            numiters = numiters+1;
%             fprintf( 1, 'After %d steps, grew by %f, total %f, remaining %f.\n', numiters, lengthgrown1, lengthgrown, remaininglength );
            continue;
        else
            if numiters==0
                xxxx = 1;
            end
            break;
        end
    end
    if ~ok
        fprintf( 1, 'Failed to conclude streamline growth after %d iterations, grew %f, remaining %f.\n', ...
            numiters, lengthgrown, remaininglength );
        alllengthgrown
        xxxx = 1;
    end    
    validStreamline( m, s );
    
    if lengthgrown > lengthToGrow * 1.000001
        xxxx = 1;
    end
    
    if lengthgrown < 1e-3
        xxxx = 1;
    end
end

% function checkvalidstreamlinepoint( m, s, si )
%     badcells = s.vxcellindex > size(m.tricellvxs,1);
%     if any( badcells)
%         warning('%s: Invalid cell indexes:', mfilename() );
%         fprintf( 1, ' %d', find( badcells ) );
%         fprintf( 1, '\n' );
%     end
%     if abs(sum(s.barycoords(si,:))-1) > 1e-10
%         warning('%s: Invalid barycoords.  cell %d bc %f %f %f', ...
%             mfilename(), s.vxcellindex(si), s.barycoords(si,:) );
%     end
% end
