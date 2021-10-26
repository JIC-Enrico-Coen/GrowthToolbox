function isat = atTime( currenttime, timepoint, timestep )
%isat = atTime( currenttime, timepoint, timestep )
%   Determine whether currenttime is within timestep/2 of timepoint.
%
%   This procedure is designed to satisfy the following property concerning
%   successive calls of atTime.
%
%   Suppose that timepoint and timestep are fixed values, currenttime is
%   initially less than timepoint, and currenttime is successively
%   incremented by timestep -- specifically, it is updated by the command:
%
%   currenttime = currenttime + timestep;
%
%   Then if atTime( currenttime, timepoint, timestep ) is called for each
%   successive value of currenttime, it will return true for exactly one of
%   those values, regardless of the capriciousness of rounding errors in
%   floating point arithmetic.
%
%   In an interaction function, a typical call of this would be
%
%       if atTime( realtime, 108, dt )
%           % This code is guaranteed to be called only once in a run, at a
%           % time close to 108.
%       end

    lotime = timepoint - timestep/2;
    hitime = timepoint + timestep/2;

    nexttime = currenttime + timestep;
    nextisat = (nexttime >= lotime) && (nexttime < hitime);
    isat = ~nextisat && (currenttime >= lotime) && (currenttime < hitime);
    
    % For mathematically perfect arithmetic, it is impossible for both
    % currenttime and nexttime to satisfy (t >= lotime) && (t < hitime).
    % We cannot be sure that this will be so for computer arithmetic.
    % However, we can be sure that three consecutive values cannot all
    % satisfy the condition, provided that timestep is much larger than
    % rounding errors, so there is no need for more than a single step of
    % lookahead.
end