function w = addAIHgrowthdata( w, growthparams )
  % formatTest = max((1+abs(growthparams(:,1))) ./ (0.01+abs(growthparams(:,2))));
    OLD_AIH_DATA = 1; % formatTest > 10
    eqGrowth = 1;
    tweakAngle = 0;
    % growthparams(:,3) = pi/2 - growthparams(:,3);  % Assumes given angle is clockwise from Y.
    for ci=1:size(growthparams,1)
        if OLD_AIH_DATA
            doublingtime = growthparams(ci,1);
            anisotropy = growthparams(ci,2);
            [ rate_x, rate_y ] = growthRateFromGrowthAmount( doublingtime, anisotropy );
            p = (eqGrowth+1)/2;
            q = 1 - p;
            rate_x1 = rate_x*p + rate_y*q;
            rate_y1 = rate_x*q + rate_y*p;
            rate_x = rate_x1;
            rate_y = rate_y1;
            RATEMULT = 1;
        else
            rate_x = growthparams(ci,1);
            rate_y = growthparams(ci,2);
            RATEMULT = 5;
        end

        rate_x = rate_x*RATEMULT;
        rate_y = rate_y*RATEMULT;

        w.celldata(ci) = setThermExpLocalTensor( ...
            w.celldata(ci), ...
            rate_x, ...
            rate_y, ...
            growthparams(ci,3)+tweakAngle );
       % gt = mesh.celldata(ci).cellThermExpGlobalTensor;
       % [ major, minor, theta ] = growthParamsFromTensor( gt );
       % checkangle = growthparams(ci,3) - theta;
       % fprintf( 1, '%s: [ %f, %f, %f ]    [ %f, %f, %f ]  %f\n', ...
       %     mfilename(), growthparams(ci,:), major, minor, theta, checkangle );
    end
end

