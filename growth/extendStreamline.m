function [m,s,timeGrown] = extendStreamline( m, s, timeToGrow, noncolliders, currentSimTime )
%[m,s,lengthgrown] = extendStreamline( m, s, lengthToGrow, noncolliders )
%   Extend the streamline s of m by a distance lengthToGrow, or until
%   unable to go further.
%
%   currentSimTime is the current absolute simulation time.

% fprintf( 1, 'Extending streamline %d by %f.\n', si, len );

    if ~validStreamline( m, s, true )
%         s.directionglobal = streamlineGlobalDirection( m, s );
%         BREAKPOINT( 'Invalid streamline.\n' );
    end
    
    params = getTubuleParamsModifiedByMorphogens( m, s, { 'plus_growthrate' } );
    lengthToGrow = params.plus_growthrate * timeToGrow;
    
    timeGrown = 0;
    lengthgrown = 0;
    
    if isemptystreamline(s)
        return;
    end

    if length(s.vxcellindex)==1
        xxxx = 1;
    end
    
    CLOSE = 1e-5 * m.globalProps.timestep;
    
    if timeToGrow < CLOSE
        return;
    end
    
    remainingtime = timeToGrow;
    
    if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
        xxxx = 1;
    end
    MAXITERS = 1000;
    numiters = 0;
    ok = true;
    alllengthgrown = [];
%     fprintf( 1, 'Growing streamline for %f seconds.\n', remainingtime );
    while remainingtime > CLOSE
%         s1 = s;
        [m,s,extended,remainingtime,lengthgrown1] = extrapolateStreamline( m, s, currentSimTime, remainingtime, noncolliders );
        if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
            xxxx = 1;
        end
        if ~extended
            xxxx = 1;
        end
        alllengthgrown(end+1) = lengthgrown1;
        lengthgrown = lengthgrown + lengthgrown1;
%         currentSimTime = currentSimTime + lengthgrown1/params.plus_growthrate
        if extended
            if numiters >= MAXITERS
                ok = false;
                break;
            end
            numiters = numiters+1;
%             fprintf( 1, 'After %d steps, grew by %f, total %f, remaining time %f.\n', numiters, lengthgrown1, lengthgrown, remainingtime );
            continue;
        else
            if numiters==0
                xxxx = 1;
            end
            break;
        end
    end
    if ~ok
        fprintf( 1, 'Failed to conclude streamline growth after %d iterations, grew %f, remaining time %f.\n', ...
            numiters, lengthgrown, remainingtime );
        alllengthgrown
        xxxx = 1;
    end    
    validStreamline( m, s );
    
    timeGrown = timeToGrow - remainingtime; % lengthgrown/params.plus_growthrate;
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
