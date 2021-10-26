function r = rand_ac( order, coherence )
%r = rand_ac( order, coherence )
%   Create a generator for uniformly distributed random numbers with zero
%   mean, unit standard deviation, and specified smoothness and
%   autocorrelation time.
%
%   The random numbers are created by multiple smoothing passes.  ORDER
%   specifies the number of passes.  The more passes, the smoother the
%   resulting sequence.  3 is generally enough.  Plots of the resulting
%   sequences show very little difference between this and any higher
%   value.
%
%   COHERENCE is (roughly) the number of steps of the sequence over which
%   the process should lose its autocorrelation.  This value does not have
%   to be an integer.  It should be at least 10, preferably 30 or more.
%   If you are using this to supply random inputs to a simulation running
%   with a time step of dt, and desire a coherence time of t, pass t/dt as
%   the coherence parameter.
%
%   The structure returned contains three components:
%       r.state is the state of the random number generator, a vector of
%           ORDER+1 elements.
%       r.a and r.b are 1*ORDER vectors containing the mixing coefficients
%           which express each smoothed sequence in terms of the previous
%           one:
%               newstate(i+1) = a(i)*r.state(i+1) + b(i)*newstate(i).
%           The values in r.a are chosen to give the desired coherence
%           interval, and the values in r.b are chosen to give a standard
%           deviation of 1 to each smoothed sequence.
%
%   See also: nextrand_ac.

    % Multiple smoothing passes tend to increase the coherence interval in
    % proportion to the square root, so we correct for that.
    a1 = 1 - sqrt(order+1)/(coherence);
    a = a1*ones(1,order);  % Using different values for different elements
                           % of the A vector is not useful.
    % The construction of b is somewhat ad hoc.  b(1) is theoretically
    % derived and guarantees that r.state(2) has standard deiation 1, but
    % the remaining elements of b were chosen by magic (i.e. empirically
    % decided).  See nextrand_ac.m for how the a and b vectors are used.
    b = zeros(1,order);
    b1 = sqrt(1-a1*a1);
    if order >= 1
        b(1) = b1;
        if order >= 2
            b(2) = b1*b1/sqrt(2);  % sqrt(2) is a magic number.
            if order >= 3
                b(3) = b(2)*0.8;  % 0.8 is a magic number.
                for i=4:order
                    b(i) = b(i-1);  % This is also magic.
                end
            end
        end
    end
    r = struct( 'state', zeros(1,length(a)+1), 'a', a, 'b', b );
end
