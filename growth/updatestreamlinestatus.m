function s = updatestreamlinestatus( s, dt )
%s = updatestreamlinestatus( s, dt )
%   Update the streamline's behaviour acording to its transition
%   probabilities.
%
%   NOT USED.

    if s.status.headgrowth
        if rand(1) < 1 - exp( -s.params.prob_plus_catastrophe * dt )
            s.status.growhead = false;
        end
    else
        if rand(1) < 1 - exp( -s.params.prob_plus_rescue * dt )
            s.status.growhead = true;
        end
    end
end