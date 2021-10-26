function [ gmajor, gminor ] = growthRateFromGrowthAmount( doublingtime, anisotropy )
%[ gmajor, gminor ] = growthRateFromGrowthAmount( doublingtime, anisotropy )
%	Given the time to double in area, and the ratio of the major and minor
%   axes when the area has doubled, compute the growth rates along the
%   major and minor axes.

    doublemajor = sqrt(2*anisotropy);
    doubleminor = doublemajor/anisotropy;
    gmajor = log(doublemajor)/doublingtime;
    gminor = log(doubleminor)/doublingtime;
end
