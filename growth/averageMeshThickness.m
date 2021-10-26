function [avth,minth,maxth] = averageMeshThickness( m )
    thicknesses = meshThickness( m );
    avth = sum(thicknesses)/length(thicknesses);
    minth = min(thicknesses);
    maxth = max(thicknesses);
end
