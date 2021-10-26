function [cmap,crange] = stresscolormap( maxval, nsteps )
    if length(maxval)==2
        maxval = maxval(2);
    end
    stepsPerInterval = [2 1 1 2 2 5 2]; % [10 5 5 10 10 50 10];  % 100
    baseNumSteps = sum(stepsPerInterval);
    if (nargin < 2) || isempty(nsteps)
        nsteps = 100;
    end
    stepsMult = round( nsteps/baseNumSteps );
    if stepsMult > 1
        stepsPerInterval = stepsPerInterval * stepsMult;
    end
    cmap = colorSteps( [ [1 1 1]; ...
                         [0 0 1]; ...
                         [0 1 1]; ...
                         [0 1 0]; ...
                         [1 1 0]; ...
                         [1 0 0]; ...
                         [1 0 1]; ...
                         [0 0 0] ], stepsPerInterval );
    if maxval <= 10
        crange = [0 10];
    else
        if maxval >= 1000
            maxval = 1000;
        end
        crange = [0 maxval];
        extra = ceil((maxval-10)*size(cmap,1)/10);
        extramap = ones(extra,3)*0.3;
        cmap = [cmap; extramap ];
    end
end
