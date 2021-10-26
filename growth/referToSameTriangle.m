function [ci, bc1, bc2] = referToSameTriangle( m, ci1, bc1, ci2, bc2 )
%[ci, bc1, bc2] = referToSameTriangle( m, ci1, bc1, ci2, bc2 )
%   ci1 and ci2 are triangles of m, and bc1 and bc2 the respective
%   barycentric coords in a point in each triangle. This procedure attempts
%   to express both points as barycentric coordinates in a single triangle.
%   If it fails then ci will be empty.
%
%   This procedure fails too readily. What we really want to do is find
%   which triangles each point belongs to, and find a common member.

    if ci1==ci2
        ci = ci1;
    else
        % Try to transfer bc2 to ci1.
        bc2a = transferBC( m, ci2, bc2, ci1 );
        if ~isempty( bc2a )
            % If that worked, both points are referenced to ci1.
            bc2 = bc2a;
            ci = ci1;
        else
            % Try to transfer bc1 to ci2.
            bc1a = transferBC( m, ci1, bc1, ci2 );
            if ~isempty( bc1a )
                % If that worked, both points are referenced to ci2.
                bc1 = bc1a;
                ci = ci2;
            else
                % Otherwise fail.
                ci = [];
            end
        end
    end
    
    ci = ci(:); % Fixing Matlab's vectors.
end
