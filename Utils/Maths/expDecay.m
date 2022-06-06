function retention = expDecay( t, retentionrate )
% A quantity is initially 1, and declining exponentially with time. In one
% unit of time it decays to RETENTIONRATE (a value between 0 and 1). This
% procedure calculates the value after a given time T. This is normally
% RETENTIONRATE^T, but there are a few edge cases the code has to consider.
%
% Either or both of T and RETENTIONRATE can be arrays.

    % Trim retentionrate to the meaningful range.
    rr = max( min( retentionrate, 1 ), 0 );
    
    if t==0
        % 0^0 is deemed to be 0, anything_else^0 is 1.
        retention = ones(size(rr));
        retention(rr==0) = 0;
    else
        retention = rr.^t;
    end
end
