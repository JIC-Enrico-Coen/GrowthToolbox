function d = decayByHalfLife( halflife, time )
%d = decayByHalfLife( halflife, time )
%   If a value decays exponentially with a certain half-life, calculate
%   what fraction remains after a certain time.

    d = exp(-log(2)*time/halflife);
end