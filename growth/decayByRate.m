function d = decayByRate( rate, time )
%d = decayByRate( rate, time )
%   If a value decays exponentially at a certain rate, calculate what
%   fraction remains after a certain time.

    d = exp(-rate*time);
end